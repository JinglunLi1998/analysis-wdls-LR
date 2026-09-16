# CONTINUITY

## [PLANS]

- 2026-09-16T00:00Z [USER] Add a standalone Long-read pVACnc WDL test module before integrating it into `immuno_longread.wdl`.

## [DECISIONS]

- 2026-09-16T00:00Z [USER] Reuse `jinglunli/pvacnc:0.2.3` for the first Long-read WDL test; do not create a new Docker image until a Long-read-specific container need is demonstrated.
- 2026-09-16T00:00Z [CODE] Preserve the existing Long-read canonical pVACseq command/settings. Extract only its RNA readcount plus StringTie GX/TX VCF annotation steps as a reusable WDL subworkflow.

## [PROGRESS]

- 2026-09-16T00:00Z [TOOL] Confirmed this branch contains PacBio HiFi Long-read DNA/RNA/immuno WDLs, including pbmm2, DeepSomatic, Clair3, HiPhase, minimap2 and StringTie3.
- 2026-09-16T00:00Z [CODE] Added `pvacseq_longread_annotation.wdl`, preserving the existing Long-read RNA readcount and StringTie GX/TX annotation calls as a shared indexed-VCF boundary. Refactored canonical `pvacseq_longread.wdl` to consume that boundary without changing its pVACseq task inputs.
- 2026-09-16T00:00Z [CODE] Added standalone `pvacnc_longread.wdl` plus ORFanage, TransDecoder, preparation and pVACview tool WDLs. The module runs with-`e` and no-`e` ORF lanes from existing Long-read outputs and uses `jinglunli/pvacnc:0.2.3`; `immuno_longread.wdl` remains unchanged.
