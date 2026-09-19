// Ported from pipeline_ref/Snakefile rule `statisti_call` (lines 569-590), a
// Snakemake `script:` rule wrapping
// pipeline_ref/scripts/tradis_essentiality_wscore_fixed.py - the
// essentiality-calling core. Wraps bin/tradis_essentiality_wscore_fixed.py.
//
// Same pandas container as SITES2GENES/SAM2SITES; this script additionally
// needs numpy/scipy/matplotlib, pip-installed into the task's own work dir
// (Apptainer mounts the container read-only) rather than pip-installed into
// the container itself. numpy is pinned explicitly alongside scipy so pip
// doesn't resolve a newer numpy that's ABI-incompatible with this
// container's pre-built pandas.
//
// Tried routing this through Wave instead (build a container on demand from
// a conda spec) - the scaffold's `wave` profile has freeze mode enabled,
// which requires a container registry you own to push builds to, and
// (worse) `-profile wave` reroutes every process's container resolution
// through Wave, not just this one, breaking cache/all pulls pipeline-wide.
// Not worth the infrastructure for one script's two extra libraries.
process STATISTI_CALL {
    tag "${meta.id}"

    input:
    tuple val(meta), path(s2g)

    output:
    tuple val(meta), path("${meta.id}-genes_insertions.essen.csv"),    emit: essen
    tuple val(meta), path("${meta.id}-genes_insertions.ambig.csv"),    emit: ambig
    tuple val(meta), path("${meta.id}-genes_insertions.all.csv"),      emit: all
    tuple val(meta), path("${meta.id}-genes_insertions.nonessen.csv"), emit: nonessen
    tuple val(meta), path("${meta.id}-genes_insertions_QC_and_changepoint_plots.pdf"), emit: qc_pdf, optional: true

    script:
    """
    # Apptainer mounts the container image read-only, so pip can't install
    # into its site-packages (or use \$HOME/.cache - unreliable/unwritable
    # under Apptainer's user mapping too). Install into this task's own
    # work dir instead, which is always writable. numpy is pinned explicitly
    # so scipy's resolver doesn't grab one ABI-incompatible with this
    # container's pre-built pandas.
    pip install --quiet --no-cache-dir --target ./pylibs numpy==1.26.4 scipy==1.13.1 matplotlib==3.9.2
    export PYTHONPATH="\${PWD}/pylibs:\${PYTHONPATH:-}"

    tradis_essentiality_wscore_fixed.py \
        --input ${s2g} \
        --output-all ${meta.id}-genes_insertions.all.csv \
        --output-essen ${meta.id}-genes_insertions.essen.csv \
        --output-ambig ${meta.id}-genes_insertions.ambig.csv \
        --output-nonessen ${meta.id}-genes_insertions.nonessen.csv
    """
}
