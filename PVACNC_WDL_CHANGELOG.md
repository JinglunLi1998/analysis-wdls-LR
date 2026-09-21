# Long-read pVACnc WDL changelog

This file tracks workflow contracts, task wiring and published outputs. Docker
implementation changes are tracked separately in the pVACnc image
`CHANGELOG.md`.

| Date/version | Git state | WDL changes | Validation |
|---|---|---|---|
| 2026-09-16, initial LR module | `fc5b583` (`pvacnc-longread`) | Added standalone `pvacnc_longread.wdl`; consumes completed LR RNA BAM, with-`-e` StringTie3 GTF and annotated VCF; runs no-`-e` StringTie3 plus parallel ORFanage and TransDecoder lanes. | Initial structural checks completed. |
| 2026-09-16, updated base | `415593a` | Merged the current `analysis-wdls/main` base into the Long-read branch. | Merge completed. |
| 2026-09-16, immuno integration | `6c34b90` | Integrated pVACnc into `immuno_longread.wdl` behind `enable_pvacnc=false`; passed the phased proximal VCF/TBI directly from the somatic workflow; published separate ORFanage and TransDecoder bundles. | MiniWDL import-graph checks passed at that state. |
| 2026-09-16, pVACtools 7.1.2 | `25bc6c2` | Updated Long-read pVACtools callers and pVACnc inputs to the 7.1.2 interface without assigning new threshold defaults. | MiniWDL checks passed at that state. |
| 2026-09-17, pVACnc `0.2.4` | Working tree, not yet committed | Updated preparation defaults to `0.2.4`; allowed empty no-`e` rescue during pVACview annotation. | NTR004 rerun passed the earlier pVACview failure and reached TransDecoder preparation. |
| 2026-09-17, pVACnc `0.2.5` | Working tree, not yet committed | Updated all preparation defaults and the standalone YAML to `0.2.5`. Preparation tasks expose candidate counts. Each ORF lane conditionally runs pVACseq/pVACview only when its count is greater than zero; a valid empty lane publishes empty prediction arrays while the parallel lane continues. Rebuilt `workflows.zip`. | Python/shell checks and empty filtering/routing/builder mocks passed. Cluster-side MiniWDL validation and the NTR004 `0.2.5` integration run remain pending. |
| 2026-09-21, pVACview memory | Working tree, not yet committed | Increased `pvacncAnnotatePvacview` memory from 4 GB to 16 GB. The NTR004 TransDecoder annotation was killed with exit 137 at 4 GB; its annotation-only recovery succeeded with a measured peak of 5.75 GB. Candidate semantics are unchanged. | NTR004 annotation-only recovery job `259892` completed successfully; `workflows.zip` rebuilt after the permanent WDL change. |

## Required entry for every future WDL change

Record the date, affected files/tasks, Docker tag expected by the WDL, whether
candidate semantics changed, Git commit (or `not yet committed`), validation
performed and the result location. Do not combine Docker implementation history
with WDL workflow history.
