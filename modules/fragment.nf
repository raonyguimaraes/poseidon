process build_fragments {
    label 'bioruby'

    //errorStrategy { task.exitStatus = 1 ? 'ignore' :  'terminate' }

    input:
        tuple val(name), path(aln), path(bp), val(recombination)

    output: 
        tuple val(name), path("fragments/fragment_*"), path("fragments/fragment_*/aln/*.nt_ali.checked.nogaps.fasta"), path("fragments/fragment_*/aln/*.aa_ali.checked.nogaps.fasta"), emit: fragments
        tuple val(name), path('bp.tsv'), emit: breakpoints
        
    script:
    """
    if [ ${recombination} == "true" ]; then
        fragments_built.rb ${aln} ${bp}
    else
        # dummy
        mkdir -p fragments/fragment_x/aln
        touch fragments/fragment_x/aln/x.nt_ali.checked.nogaps.fasta
        touch fragments/fragment_x/aln/x.aa_ali.checked.nogaps.fasta
        touch bp.tsv
    fi
    """
}

process frag_publish {
    publishDir "${params.output}/${name}/html/", mode: 'copy', pattern: "fragment_*" 
    label 'bioruby'

    input:
        tuple val(name), file(dirs)

    output: 
        path "fragment_*", type: 'dir'

    script:
    """
    for DIR in fragment_*; do 
        cp -r \$DIR \$(echo \$DIR | awk 'BEGIN{FS="_"};{print \$1"_"\$2}')
    done
    """
}