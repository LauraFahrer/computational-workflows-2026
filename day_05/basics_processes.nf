params.step = 0
params.zip = 'zip'
params.gzip = 'gzip'
params.bzip2 = 'bzip2'


process SAYHELLO {
    debug(true)

    script:
    """
    echo 'Hello'
    """
}

process SAYHELLO_PYTHON {
    debug(true)

    script:
    """
    python -c "print('Hello World!')" 
    """
}

process SAYHELLO_PARAM {
    debug(true)

    input: 
    val param

    script:
    """
    echo '${param}'
    """
}

process SAYHELLO_FILE {
    debug(true)
        
    input: 
    val param

    script:
    """
    echo '${param}' > hello_world.txt
    echo "File is saved in the work directory of nextflow"
    """
}

process UPPERCASE {
    debug(true)
        
    input: 
    val param

    script:
    """
    declare -u PARAM
    PARAM='${param}'
    echo "\$PARAM" > hello_world_uppercase.txt
    
    """
 
    output:
    path 'hello_world_uppercase.txt'
}

process PRINTUPPER {
    debug(true)
        
    input: 
    path param

    script:
    """
    cat ${param}
    """
}

process COMPRESS {
    debug(true)

    input:
    path param

    script:
    """
    ${params.zip} hello_world_compressed.${params.zip} ${param}
    """

    output:
    path "hello_world_compressed.zip"
}

process COMPRESS_ALL_TYPES {
    debug(true)

    input:
    path param

    script:
    """
    ${params.zip} hello_world_compressed.${params.zip} ${param}
    ${params.gzip} -c ${param} > hello_world_compressed.gz
    ${params.bzip2} -c ${param} > hello_world_compressed.bz2
    """
    
    output:
    path "hello_world_compressed.zip"
    path "hello_world_compressed.gz"
    path "hello_world_compressed.bz2"
}

process WRITETOFILE {
    debug(true)

    publishDir 'results', mode: 'copy'

    input:
    val param

    script:
    """
    cat > names.tsv << 'EOF'
    ${param.collect { "${it.name}\t${it.title}" }.join('\n')}
    //EOF
    """
}



workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be able to print the output to the console)
    if (params.step == '1') {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == '2') {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == '3') {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == '4') {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == '5') {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == '6') {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the parameter "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == '7') {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        zip_ch = COMPRESS(out_ch)
        zip_ch.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == '8') {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        compressed_ch = COMPRESS_ALL_TYPES(out_ch)
        compressed_ch[0].view()
        compressed_ch[1].view()
        compressed_ch[2].view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == '9') {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        WRITETOFILE(in_ch.collect())
    }
}