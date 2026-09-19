// Ported from nfcore_HTTM/modules/bwa_index.nf (originally: pipeline/Snakefile rule `index_genome`).
process BWA_INDEX {

    input:
    path fasta

    output:
    tuple path(fasta), path("${fasta}.amb"), path("${fasta}.bwt"), path("${fasta}.sa"), path("${fasta}.ann"), path("${fasta}.pac"), emit: index
    tuple val("${task.process}"), val('bwa'), eval('bwa 2>&1 | grep -m1 Version | sed "s/Version: //" || true'), emit: versions, topic: versions

    script:
    """
    bwa index ${fasta}
    """
}
