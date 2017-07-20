#!/usr/bin/python

# Copyright (c) 2017 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Generate csv files for the chapter "CSIT Release Notes" from json files
generated by Jenkins' jobs.
"""

from sys import exit as sys_exit
from os import walk
from os.path import join
from math import sqrt
from argparse import ArgumentParser, RawDescriptionHelpFormatter
from json import load


EXT_JSON = ".json"
EXT_TMPL = ".template"
EXT_CSV = ".csv"


def get_files(path, extension):
    """Generates the list of files to process.

    :param path: Path to files.
    :param extension: Extension of files to process. If it is the empty string,
    all files will be processed.
    :type path: str
    :type extension: str
    :returns: List of files to process.
    :rtype: list
    """

    file_list = list()
    for root, _, files in walk(path):
        for filename in files:
            if extension:
                if filename.endswith(extension):
                    file_list.append(join(root, filename))
            else:
                file_list.append(join(root, filename))

    return file_list


def parse_args():
    """Parse arguments from cmd line.

    :returns: Parsed arguments.
    :rtype ArgumentParser
    """

    parser = ArgumentParser(description=__doc__,
                            formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument("-i", "--input",
                        required=True,
                        help="Input folder with data files.")
    parser.add_argument("-o", "--output",
                        required=True,
                        help="Output folder with csv files and templates for "
                             "csv files.")
    return parser.parse_args()


def calculate_stats(data):
    """Calculate statistics:
    - average,
    - standard deviation.

    :param data: Data to process.
    :type data: list
    :returns: Average and standard deviation.
    :rtype: tuple
    """

    if len(data) == 0:
        return None, None

    def average(items):
        """Calculate average from the items.

        :param items: Average is calculated from these items.
        :type items: list
        :returns: Average.
        :rtype: float
        """
        return float(sum(items)) / len(items)

    avg = average(data)
    variance = [(x - avg) ** 2 for x in data]
    stdev = sqrt(average(variance))

    return avg, stdev


def write_line_to_file(file_handler, item):
    """Write a line to the csv file.

    :param file_handler: File handler for the csv file. It must be open for
     writing text.
    :param item: Item to be written to the file.
    :type file_handler: BinaryIO
    :type item: dict
    """

    mean = "" if item["mean"] is None else "{:.1f}".format(item["mean"])
    stdev = "" if item["stdev"] is None else "{:.1f}".format(item["stdev"])
    change = "" if item["change"] is None else "{:.0f}%".format(item["change"])
    file_handler.write("{},{},{},{}\n".format(item["old"], mean, stdev, change))


def main():
    """Main function to generate csv files for the chapter "CSIT Release Notes"
    from json files generated by Jenkins' jobs.
    """

    args = parse_args()

    json_files = get_files(args.input, EXT_JSON)
    tmpl_files = get_files(args.output, EXT_TMPL)

    if len(json_files) == 0:
        print("No json data to process.")
        exit(1)

    if len(tmpl_files) == 0:
        print("No template files to process.")
        exit(1)

    # Get information from template files
    csv_data = list()
    for tmpl_file in tmpl_files:
        with open(tmpl_file, mode='r') as file_handler:
            for line in file_handler:
                line_list = line.split(',')
                try:
                    csv_data.append({
                        "ID": line_list[0],
                        "type": line_list[0].rsplit("-", 1)[-1],
                        "old": ",".join(line_list[1:])[:-1],
                        "last_old": line_list[-1][:-1],
                        "rates": list(),
                        "mean": None,
                        "stdev": None,
                        "change": None})
                except IndexError:
                    pass

    # Update existing data with the new information from json files
    for json_file in json_files:
        with open(json_file) as file_handler:
            tests_data = load(file_handler)
            for item in csv_data:
                try:
                    rate = tests_data["data"][item["ID"]]["throughput"]["value"]
                    item["rates"].append(rate)
                except KeyError:
                    pass

    # Add statistics
    for item in csv_data:
        mean, stdev = calculate_stats(item["rates"])
        if mean is not None:
            mean = mean / 1000000
            old = float(item["last_old"])
            item["mean"] = mean
            item["change"] = ((mean - old) / old) * 100
            item["stdev"] = stdev / 1000000

    # Sort the list, key = change
    csv_data.sort(key=lambda data: data["change"], reverse=True)

    # Write csv files
    for tmpl_file in tmpl_files:
        csv_file = tmpl_file.replace(EXT_TMPL, EXT_CSV)
        with open(csv_file, "w") as file_handler:
            for item in csv_data:
                if "pdr_" in csv_file \
                        and "_others" not in csv_file \
                        and item["type"] == "pdrdisc" \
                        and item["change"] >= 9.5:
                    write_line_to_file(file_handler, item)
                elif "pdr_" in csv_file \
                        and "_others" in csv_file \
                        and item["type"] == "pdrdisc" \
                        and item["change"] < 9.5:
                    write_line_to_file(file_handler, item)
                elif "ndr_" in csv_file \
                        and "_others" not in csv_file \
                        and item["type"] == "ndrdisc" \
                        and item["change"] >= 9.5:
                    write_line_to_file(file_handler, item)
                elif "ndr_" in csv_file \
                        and "_others" in csv_file \
                        and item["type"] == "ndrdisc" \
                        and item["change"] < 9.5:
                    write_line_to_file(file_handler, item)


if __name__ == "__main__":
    sys_exit(main())