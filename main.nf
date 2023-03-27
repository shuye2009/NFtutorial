#! /usr/bin/env nextflow


println "\nI want to BLAST $params.query to $params.dbDir/$params.dbName using $params.threads CPUs and output it to $params.outdir\n"

def helpMessage() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --query QUERY.fasta --dbDir "blastDatabaseDirectory" --dbName "blastPrefixName"

        Mandatory arguments:
         --query                        Query fasta file of sequences you wish to BLAST
         --dbDir                        BLAST database directory (full path required)
         --dbName                       Prefix name of the BLAST database

       Optional arguments:
        --outdir                       Output directory to place final BLAST output
        --outfmt                       Output format ['6']
        --options                      Additional options for BLAST command [-evalue 1e-3]
        --outFileName                  Prefix name for BLAST output [input.blastout]
        --threads                      Number of CPUs to use during blast job [16]
        --chunkSize                    Number of fasta records to use when splitting the query fasta file
        --app                          BLAST program to use [blastn;blastp,tblastn,blastx]
        --help                         This usage statement.
        """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

queryFile_ch = Channel
      .fromPath(params.query)
      .splitFasta(by: 1, file:true)

process runBlast {

  input:
    path queryFile

  output:
    publishDir "${params.outdir}/blastout"
    path(params.outFileName)

  script:
  """
  $params.app  -num_threads $params.threads -db $params.dbDir/$params.dbName -query $queryFile -outfmt $params.outfmt $params.options -out $params.outFileName
  """

}

workflow {
	runBlast(queryFile_ch)
	  .collectFile(name: 'blast_output_combined.txt', storeDir: params.outdir)
}
