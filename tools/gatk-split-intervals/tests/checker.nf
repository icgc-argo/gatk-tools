#!/usr/bin/env nextflow

/*
 * Copyright (c) 2019-2020, Ontario Institute for Cancer Research (OICR).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

/*
 * author Junjun Zhang <junjun.zhang@oicr.on.ca>
 *        Linda Xiang <linda.xiang@oicr.on.ca>
 */

nextflow.preview.dsl=2

params.scatter_count = 3
params.ref_genome_fa = ""
params.intervals = "NO_FILE"  // starting intervals from a bed file, optional


include { gatkSplitIntervals; getSecondaryFiles as getIdx } from '../gatk-split-intervals.nf' params(params)

Channel
  .fromPath(getIdx(params.ref_genome_fa), checkIfExists: true)
  .set { ref_genome_ch }

workflow {
  main:
    gatkSplitIntervals(
      params.scatter_count, \
      file(params.ref_genome_fa), \
      ref_genome_ch.collect(), \
      file(params.intervals)
    )
}
