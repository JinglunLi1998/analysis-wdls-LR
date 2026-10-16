# Long-read pVACnc

Run `definitions/pvacnc_longread.wdl` standalone, or set
`immunoLongread.enable_pvacnc: true` in the complete workflow.

## Inputs

Required upstream files are the tumor RNA BAM and index, reference-only
StringTie3 GTF, expression-annotated VEP VCF, MHC alleles and matched genome,
annotation and peptide references. The standalone input name is
`pvacncLongread.source_annotated_vcf`. A phased VCF and its index are optional.

The full workflow supplies these files from its existing DNA/RNA calls.
Canonical pVACseq prediction reports are not required. Its annotated VCF is
still obtained from the canonical pVACseq subworkflow.

## Processing

StringTie3 runs with `-L` for Long-read assembly. ORFanage (`BEST`) and
TransDecoder (30-aa minimum) process the reference-only and assembled models
in parallel.

Preparation retains PASS alleles outside annotated reference CDSs, projects
them into predicted ORFs and retains distinct protein-changing no-`-e`
events even when with-`-e` ORFs overlap. Exact WT/MT protein equivalents for
the same allele and strand prefer the successfully built with-`-e` event.
Each caller produces a derived VCF for pVACseq. No-`-e` candidates retain
sample-specific identifiers and StringTie expression. Reference MANE Select,
Canonical and TSL fields are blank; pVACview displays `Transcript Pass` as
`de novo`, exempting only that transcript-quality check.

Each caller handles zero candidates independently by skipping prediction and
pVACview annotation. Preparation and audit files are still published.

## Images

| Tool | Default image |
|---|---|
| StringTie3 | `quay.io/biocontainers/stringtie:3.0.3--h29c0135_0` |
| ORFanage | `quay.io/biocontainers/orfanage:1.2.0--heaafb18_2` |
| TransDecoder | `quay.io/biocontainers/transdecoder:6.0.0--pl5321hdfd78af_0` |
| Preparation and pVACview annotation | `jinglunli/pvacnc:latest` |
| Ribo-seq support | `jinglunli/pvacnc:latest` |
| pVACseq | `griffithlab/pvactools:7.1.2` |

Preparation and Ribo-seq images can be overridden independently. WDL interface
versions and Docker image versions are separate. Both callers use the SR `0.3.5` interface. The contents of `latest` are
resolved when the workflow runs.

## Outputs

Integrated results are grouped under `pvacnc/orfanage/` and
`pvacnc/transdecoder/`. Both callers publish model files, indexed VCFs,
mapping/routing/effect tables, skipped-candidate tables, noncanonical ORF
blocks, preparation audits, prediction logs and pVACview reports.

Preparation files and annotation logs use caller-specific prefixes.
Standard prediction filenames are retained within each caller's MHC-I,
MHC-II and combined directories.

Standalone ORFanage model outputs are now `with_e_orfanage_outputs` and
`no_e_orfanage_outputs` arrays, matching the TransDecoder model arrays.
They replace the previous scalar `with_e_orfanage_gtf` and
`no_e_orfanage_gtf` outputs.

## Optional Ribo-seq support

Set `pvacncLongread.enable_riboseq_support: true` and supply equal-length
`riboseq_bams`, `riboseq_bais` and `riboseq_sample_labels` arrays. In the full
workflow, use `immunoLongread.enable_pvacnc_riboseq_support` and the corresponding
`immunoLongread.pvacnc_riboseq_*` inputs.

Each nonempty caller publishes six tables: per-BAM, allele, candidate and run
summaries, plus per-BAM ORF support and ORF candidate summaries.

Evidence distinguishes SNV ALT support, variant-coordinate coverage and
aligned-base coverage in the residual noncanonical block containing the
variant's full REF span. The reference GTF is passed to both callers for
CDS and stop-codon masking. Region support
requires matching BAM/ORF strand, without a P-site or reading-frame test.
Coordinate coverage alone does not establish translation.

Default mapping/base quality thresholds are zero. Secondary, supplementary,
QC-fail and duplicate alignments are retained unless excluded through inputs.
Ribo evidence does not alter candidate filtering or pVACview tiers.

## Validation

MiniWDL checks cover the standalone module and full Long-read import graph.
Runtime validation with the updated images and Long-read inputs remains
required before accepting a new production run.
