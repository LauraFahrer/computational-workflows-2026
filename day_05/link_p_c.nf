#!/usr/bin/env nextflow

process SPLITLETTERS {
    debug(true)

    input:
    tuple val(block_size), val(input_str), val(out_name)

    output:
    path "${out_name}_*.txt"

    script:
    """
    python -c "
    s = '''${input_str}'''
    n = ${block_size}
    for i in range(0, len(s), n):
        with open('${out_name}_' + str(i // n) + '.txt', 'w') as f:
            f.write(s[i:i+n])
    "
    """
} 

process CONVERTTOUPPER {
    debug(true)

    publishDir 'results', mode: 'copy'

    input:
    path chunk

    output:
    path "*_upper.txt"

    script:
    """
    tr '[:lower:]' '[:upper:]' < ${chunk} > ${chunk.baseName}_upper.txt
    """
}

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet
    
    in_ch = channel
        .fromPath('samplesheet_2.csv')
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.block_size.toInteger(),
                row.input_str,
                row.out_name
            )
        }

    // split the input string into chunks
    splitted_ch = SPLITLETTERS(in_ch)
    splitted_ch.view()


    // lets remove the metamap to make it easier for us, as we won't need it anymore
    in_ch = channel
    .fromPath('samplesheet_2.csv')
    .splitCsv(header: true)
    .map { row ->
        tuple(
            row.block_size.toInteger(),
            row.input_str,
            row.out_name
        )
    }

    // convert the chunks to uppercase and save the files to the results directory
    uppercase_ch = CONVERTTOUPPER(splitted_ch.flatten())
    uppercase_ch.view()



}