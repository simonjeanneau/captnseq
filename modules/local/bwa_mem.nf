// Ported from nfcore_HTTM/modules/bwa_mem.nf (originally the `bwa mem` half of
// pipeline/Snakefile rule `map_reads`).
process BWA_MEM {
    tag "${meta.id}"

    input:
    tuple val(meta), path(r1), path(r2)
    tuple path(fasta), path(amb), path(bwt), path(sa), path(ann), path(pac)

    output:
    tuple val(meta), path("${meta.id}.sam"), emit: sam

    script:
    """
    bwa mem \
        -R "@RG\\tID:${meta.id}\\tSM:${meta.id}\\tPL:ELEMENT" \
        -k 10 \
        -t ${task.cpus} \
        ${fasta} \
        ${r1} ${r2} > ${meta.id}.sam
    """
}
