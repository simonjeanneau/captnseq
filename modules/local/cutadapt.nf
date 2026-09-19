// Ported from nfcore_HTTM/modules/cutadapt.nf (originally: pipeline/Snakefile rule `cutadapt`).
process CUTADAPT {
    tag "${meta.id}"

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}-R1cutadapt.fq"), path("${meta.id}-R2cutadapt.fq"), emit: reads
    path "${meta.id}-R1cutadapt.log", emit: log
    tuple val("${task.process}"), val('cutadapt'), eval('cutadapt --version'), emit: versions, topic: versions

    script:
    """
    cutadapt \
        --adapter '${params.adapter_seq}' \
        -A '${params.adapter_seq}' \
        --minimum-length ${params.trim_minlen} \
        --cores ${task.cpus} \
        --output ${meta.id}-R1cutadapt.fq \
        --paired-output ${meta.id}-R2cutadapt.fq \
        ${r1} ${r2} \
        > ${meta.id}-R1cutadapt.log
    """
}
