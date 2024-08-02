require "CollectionExporterDialogSection"
require "CollectionExporter"

return {
  allowFileFormats = nil, -- nil equates to all available formats
	
	allowColorSpaces = nil, -- nil equates to all color spaces

	exportPresetFields = {
		{ key = 'useCatalogAsFolder', default = false },
	},

  sectionsForTopOfDialog = CollectionExporterDialogSection.sectionsForTopOfDialog,
  processRenderedPhotos = CollectionExporter.processRenderedPhotos,
}
