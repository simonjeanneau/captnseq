// Ported from nfcore_HTTM/modules/fastp.nf (originally: pipeline/Snakefile rule `fastp`).
process FASTP {
    tag "${meta.id}"

    input:
    tuple val(meta), path(r1), path(r2)

    output:
    tuple val(meta), path("${meta.id}-R1.fq"), path("${meta.id}-R2.fq"), emit: reads
    path "QC/${meta.id}.json", emit: json
    path "QC/${meta.id}.html"
    path "FAILED/${meta.id}.fq"
    path "UNPAIRED/${meta.id}-R1.fq"
    path "UNPAIRED/${meta.id}-R2.fq"
    tuple val("${task.process}"), val('fastp'), eval('fastp --version 2>&1 | sed "s/fastp //"'), emit: versions, topic: versions

    script:
    """
    mkdir -p QC FAILED UNPAIRED
    fastp --disable_adapter_trimming \
        --cut_right \
        --cut_right_window_size 4 \
        --cut_mean_quality ${params.fastp_qual_threshold} \
        --length_required ${params.trim_minlen} \
        -w ${task.cpus} \
        -i ${r1} -o ${meta.id}-R1.fq \
        -I ${r2} -O ${meta.id}-R2.fq \
        -j QC/${meta.id}.json -h QC/${meta.id}.html \
        --failed_out FAILED/${meta.id}.fq \
        --dont_eval_duplication \
        --unpaired1 UNPAIRED/${meta.id}-R1.fq --unpaired2 UNPAIRED/${meta.id}-R2.fq
    """
}
