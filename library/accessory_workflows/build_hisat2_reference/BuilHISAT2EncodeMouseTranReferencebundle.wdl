task BuildHISAT2EncodeMouseTrans {
  String ref_name ## name of the tar.gz file without tar.gz suffix
  String gtf_version
  command {
    
    ##download fasta
    wget http://woldlab.caltech.edu/~diane/genome/mm10-M4-male/male.mm10.chrom-ENCFF001RTP_ERCC_spikein.fa
    mv male.mm10.chrom-ENCFF001RTP_ERCC_spikein.fa genome.fa
    ##download gtf file
    wget http://woldlab.caltech.edu/~diane/genome/mm10-M4-male/gencode.vM${gtf_version}-tRNAs-ERCC.gff
    mv gencode.vM${gtf_version}-tRNAs-ERCC.gff transcripts.gtf
    ##extract transcriptome fa
    gffread -w transcriptome.fa -g genome.fa transcripts.gtf
    ##building index
    hisat2-build -p 8 transcriptome.fa ${ref_name}
    mkdir ${ref_name}
    mv *.ht2 ${ref_name}
    tar -zcvf "${ref_name}.tar.gz" "${ref_name}"
  }
  runtime {
    docker:"quay.io/humancellatlas/secondary-analysis-hisat2:v0.2.2-2-2.1.0"
    memory: "8 GB"
    disks: "local-disk 100 HDD"
    cpu: "8"
  }
  output {
    File hisat2Ref = "${ref_name}.tar.gz"
  }
}
workflow HISAT2Ref {
  String ref_name
  String gtf_version
  
  call BuildHISAT2EncodeMouseTrans {
    input:
      ref_name = ref_name,
      gtf_version = gtf_version		
  }
  output {
    File hisat2_ref = BuildHISAT2EncodeMouseTrans.hisat2Ref
  }
}
