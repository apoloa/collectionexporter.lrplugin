
local LrView = import 'LrView'

CollectionExporterDialogSection = {}

local function updateStatus( propertyTable )

  local message = nil

  propertyTable.message = message
  propertyTable.hasError = false
  propertyTable.hasNoError = true
  propertyTable.LR_cantExportBecause = nil

end

function CollectionExporterDialogSection.startDialog(_, propertyTable )

  propertyTable:addObserver( 'useCatalogAsFolder', updateStatus )

end


function CollectionExporterDialogSection.sectionsForTopOfDialog( _, propertyTable )

  local f = LrView.osFactory()
  local bind = LrView.bind
  local share = LrView.share

  local result = {
    {
      title = LOC "$$$/CollectionExporter/ExportDialog/CollectionSettings=Collection Settings",

      f:row{
        f:checkbox {
          title = LOC "$$$/CollectionExporter/ExportDialog/UseCatalogNameAsFolder=Use Catalog Name as Folder",
          value = bind 'useCatalogAsFolder',
        },
      },
    },
  }
  return result

end

