version 1.0

import "bam_readcount.wdl" as br
import "vcf_readcount_annotator.wdl" as vra
import "../tools/vcf_expression_annotator.wdl" as vea
import "../tools/index_vcf.wdl" as iv

# Shared Long-read VCF annotation boundary. It applies RNA bam-readcount and
# StringTie gene/transcript expression to an already VEP-annotated DNA VCF.
# Both canonical pVACseq and pVACnc consume this identical indexed VCF.
workflow pvacseqLongreadAnnotation {
  input {
    File detect_variants_vcf
    File detect_variants_vcf_tbi
    String sample_name
    File rnaseq_bam
    File rnaseq_bam_bai
    File reference
    File reference_fai
    File reference_dict
    Int? readcount_minimum_base_quality
    Int? readcount_minimum_mapping_quality
    File gene_expression_file
    File transcript_expression_file
    String expression_tool = "stringtie"
  }

  call br.bamReadcount as tumorRnaBamReadcount {
    input:
    vcf=detect_variants_vcf,
    vcf_tbi=detect_variants_vcf_tbi,
    sample=sample_name,
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    bam=rnaseq_bam,
    bam_bai=rnaseq_bam_bai,
    min_base_quality=readcount_minimum_base_quality,
    min_mapping_quality=readcount_minimum_mapping_quality
  }

  call vra.vcfReadcountAnnotator as addTumorRnaBamReadcountToVcf {
    input:
    vcf=tumorRnaBamReadcount.normalized_vcf,
    snv_bam_readcount_tsv=tumorRnaBamReadcount.snv_bam_readcount_tsv,
    indel_bam_readcount_tsv=tumorRnaBamReadcount.indel_bam_readcount_tsv,
    data_type="RNA",
    sample_name=sample_name
  }

  call vea.vcfExpressionAnnotator as addGeneExpressionDataToVcf {
    input:
    vcf=addTumorRnaBamReadcountToVcf.annotated_bam_readcount_vcf,
    expression_file=gene_expression_file,
    expression_tool=expression_tool,
    data_type="gene",
    sample_name=sample_name
  }

  call vea.vcfExpressionAnnotator as addTranscriptExpressionDataToVcf {
    input:
    vcf=addGeneExpressionDataToVcf.annotated_expression_vcf,
    expression_file=transcript_expression_file,
    expression_tool=expression_tool,
    data_type="transcript",
    sample_name=sample_name
  }

  call iv.indexVcf as index {
    input: vcf=addTranscriptExpressionDataToVcf.annotated_expression_vcf
  }

  output {
    File annotated_vcf = index.indexed_vcf
    File annotated_vcf_tbi = index.indexed_vcf_tbi
  }
}
