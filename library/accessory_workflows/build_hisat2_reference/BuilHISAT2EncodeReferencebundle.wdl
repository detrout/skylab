task BuildHISAT2reference{
  String ref_name ## name of the tar.gz file without tar.gz suffix
  String gtf_version  ## the actually number of gencode, ex.  27
  String dbsnp_version ## dbsnp version, integer num, ex 150
  
  command {
    wget http://woldlab.caltech.edu/~diane/genome/mm10-M4-male/gencode.vM${gtf_version}-tRNAs-ERCC.gff
    wget http://woldlab.caltech.edu/~diane/genome/mm10-M4-male/male.mm10.chrom-ENCFF001RTP_ERCC_spikein.fa
    mv male.mm10.chrom-ENCFF001RTP_ERCC_spikein.fa genome.fa
    wget hgdownload.cse.ucsc.edu/goldenPath/mm10/database/snp${dbsnp_version}Common.txt.gz
    gunzip snp${dbsnp_version}Common.txt.gz
    hisat2_extract_snps_haplotypes_UCSC.py genome.fa snp${dbsnp_version}Common.txt genome
    hisat2_extract_splice_sites.py gencode.v${gtf_version}.vM4-tRNAs-ERCC.gff > genome.ss
    hisat2_extract_exons.py gencode.v${gtf_version}.vM4-tRNAs-ERCC.gff > genome.exon
    hisat2-build -p 8 genome.fa --snp genome.snp --haplotype genome.haplotype -ss genome.ss --exon genome.exon genome_snp_tran
    
    mkdir ${ref_name}
    cp *.ht2 ${ref_name}
    tar -zcvf "${ref_name}.tar.gz" "${ref_name}"
  }
  runtime {
    docker:"quay.io/humancellatlas/secondary-analysis-hisat2:v0.2.2-2-2.1.0"
    memory: "200 GB"
    disks: "local-disk 100 HDD"
    cpu: "16"
  }
  output {
    File hisat2Ref = "${ref_name}.tar.gz"
  }
}

workflow HISAT2Ref {
  String ref_name
  String gtf_version
  String dbsnp_version

  call BuildHISAT2reference {
    input:
      ref_name = ref_name,
      gtf_version = gtf_version,
      dbsnp_version = dbsnp_version
  }
  output {
    File hisat2_ref = BuildHISAT2reference.hisat2Ref
  }
}
