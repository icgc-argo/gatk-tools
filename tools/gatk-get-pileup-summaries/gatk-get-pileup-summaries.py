#!/usr/bin/env python3

"""
Copyright (c) 2019-2020, Ontario Institute for Cancer Research (OICR).
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
Authors:
  Junjun Zhang <junjun.zhang@oicr.on.ca>
  Linda Xiang  <linda.xiang@oicr.on.ca>
"""

import os
import sys
import subprocess
import argparse

def run_cmd(cmd):
    try:
        p = subprocess.run([cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           shell=True, check=True)

    except subprocess.CalledProcessError as e:   # this is triggered when cmd returned non-zero code
        print(e.stdout.decode("utf-8"))
        print('Execution returned non-zero code: %s. Additional error message: %s' %
              (e.returncode, e.stderr.decode("utf-8")), file=sys.stderr)
        sys.exit(e.returncode)

    except Exception as e:  # all other errors go here, like unable to find the command
        sys.exit('Execution failed: %s' % e)

    return p  # in case the caller of this funtion needs p.stdout, p.stderr etc


def main():
    parser = argparse.ArgumentParser(description='GATK GetPileupSummaries')

    parser.add_argument('-j', '--jvm-mem', dest='jvm_mem', type=int,
                        help='JVM max memory in MB', default=1000)
    parser.add_argument('-R', dest='ref_fa', type=str,
                        help='Reference genome file (eg, .fa)')
    parser.add_argument('-I', dest='input_seq', type=str,
                        help='BAM/SAM/CRAM file containing reads', required=True)
    parser.add_argument('-L', dest='intervals', type=str,
                        help='One or more genomic intervals over which to operate', required=True)
    parser.add_argument('-V', dest='variants', type=str,
                        help='A VCF file containing variants and allele frequencies', required=True)
    parser.add_argument('-O', dest='output_name', type=str,
                        help='Output file name', required=True)

    args = parser.parse_args()

    output_prefix = ''
    if args.intervals:
        output_prefix = os.path.basename(args.intervals).split('.')[0] + '.'

    cmd = 'gatk --java-options "-Xmx%sm" GetPileupSummaries -I %s -L %s -V %s -O %s%s --interval-set-rule INTERSECTION' % (
            args.jvm_mem, args.input_seq, args.intervals, args.variants, output_prefix, args.output_name
        )

    if args.ref_fa:
        cmd = cmd + ' -R %s' % args.ref_fa

    run_cmd(cmd)


if __name__ == "__main__":
    main()
