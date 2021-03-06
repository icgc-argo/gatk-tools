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
 */

nextflow.enable.dsl = 2

params.tumour_reads = "NO_FILE1"
params.normal_reads = "NO_FILE2"
params.interval_file = "NO_FILE3"
params.ref_genome_fa = "NO_FILE4"
params.germline_resource = "NO_FILE5"
params.panel_of_normals = "NO_FILE6"

params.container_version = ""
params.cpus = 1
params.mem = 1  // in GB

include {gatkMutect2; getSecondaryFiles} from '../gatk-mutect2'

Channel
  .fromPath(getSecondaryFiles(params.tumour_reads, ['bai']), checkIfExists: true)
  .set { tumour_idx_ch }

Channel
  .fromPath(getSecondaryFiles(params.normal_reads, ['bai']), checkIfExists: true)
  .set { normal_idx_ch }

Channel
  .fromPath(getSecondaryFiles(params.ref_genome_fa, ['^dict', 'fai']), checkIfExists: true)
  .set { ref_genome_secondary_file }

germline_resource = Channel.fromPath(params.germline_resource)

germline_resource_idx = germline_resource.flatMap { v -> getSecondaryFiles(v, ['tbi']) }

panel_of_normals = Channel.fromPath(params.panel_of_normals)

panel_of_normals_idx = panel_of_normals.flatMap { v -> getSecondaryFiles(v, ['tbi']) }

workflow {
  main:
    gatkMutect2(
      file(params.tumour_reads),
      tumour_idx_ch,
      file(params.normal_reads),
      normal_idx_ch,
      file(params.ref_genome_fa),
      ref_genome_secondary_file.collect(),
      germline_resource.collect(),
      germline_resource_idx.collect(),
      panel_of_normals.collect(),
      panel_of_normals_idx.collect(),
      Channel.fromPath(params.interval_file).flatten()
    )
}
