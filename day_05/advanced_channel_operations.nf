params {
    step: Integer = 0
}

process PRINT_SAMPLESHEET {
    debug(true)

    input:
    path samplesheet

    script:
    """
    cat $samplesheet
    """
}

workflow{

    // Task 1 - Read in the samplesheet.
    println "params.step = '${params.step}'"

    if (params.step == 1) {

        in_ch = channel.fromPath('samplesheet.csv')
        in_ch.view { "INPUT: $it" }

        PRINT_SAMPLESHEET(in_ch)
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        in_ch = channel
            .fromPath('samplesheet.csv')
            .splitCsv(header: true)
            .map { row ->
                def meta = [
                    id: row.sample
                ]
                def fastqs = [file(row.fastq_1)]
                if (row.fastq_2) {
                    fastqs << file(row.fastq_2)
                }
                tuple(meta, fastqs)
            }

        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        in_ch = channel
            .fromPath('samplesheet.csv')
            .splitCsv(header: true)
            .map { row ->
                def meta = row
                def fastqs = [file(row.fastq_1)]
                if (row.fastq_2) {
                    fastqs << file(row.fastq_2)
                }
                tuple(meta, fastqs)
            }

        stranded_ch = in_ch
            .map { meta, fastqs -> tuple(meta.strandedness, meta, fastqs) }
            .branch {
                auto: it[0] == 'auto'
                forward:    it[0] == 'forward'
                reverse:    it[0] == 'reverse'
            }

        stranded_ch.auto.view { "Auto: $it" }
        stranded_ch.forward.view { "Forward: $it" }
        stranded_ch.reverse.view { "Reverse: $it" }
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        in_ch = channel
            .fromPath('samplesheet.csv')
            .splitCsv(header: true)
            .map { row ->
                tuple(
                row.sample,
                row.strandedness,
                file(row.fastq_1),
                file(row.fastq_2)
            )
        }
        .map { sample, strandedness, fastq1, fastq2 ->
            tuple(
                tuple(sample, strandedness),
                [fastq1, fastq2]
            )
        }
        .groupTuple()

    in_ch.view()
    }



}