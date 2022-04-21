## 2022-04-17
 
### Added
- Added natives to get all entity inputs or outputs, to find an output offset by name or to add an output action.

## 2022-04-20

### Added
- Added EntityIO_OnEntityInput_Post forward.

### Changed
- Inputs can now be changed or stopped in EntityIO_OnEntityInput forward (SM 1.11 build 6871 is required or a higher version).
- Changed EntityIO_FieldType enum to EntityIO_VariantType.
- Changed EntityIO_OnEntityInput params to store the variant in the EntityIO_VariantInfo struct.
