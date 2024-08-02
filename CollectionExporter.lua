
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrDialogs = import 'LrDialogs'

CollectionExporter = {}

local function getPhotoFolderPath(photo)
    local photoPath = photo:getRawMetadata('path')
    return photoPath:match("(.+)/[^/]+$")
end

function CollectionExporter.processRenderedPhotos( functionContext, exportContext)

    -- Make a local reference for the export parameters

    local exportSession = exportContext.exportSession
	local exportParams = exportContext.propertyTable

    local nPhotos = exportSession:countRenditions()

	local progressScope = exportContext:configureProgress {
						title = nPhotos > 1
							   and LOC ("$$$/CollectionExporter/ExportDialog/CollectionExporter=Saving ^1 photos", nPhotos )
							   or LOC "$$$/CollectionExporter/ExportDialog/CollectionExporter/One=Saving one foto from",
					}

    -- Store the failures to send it to LR
    local failures = {}
	local processes = {}

    for sourceRendition, rendition in exportContext:renditions{ stopIfCanceled = true } do
	
		-- Wait for next photo to render.

		local success, pathOrMessage = rendition:waitForRender()
		
		-- Check for cancellation again after photo has been rendered.
		
		if progressScope:isCanceled() then break end
		
		if success then
			-- Extract the photo from the rendition		
            local photo = rendition.photo
			-- Get the original path of the image from the metadata
            local photoPath = photo:getRawMetadata('path')
			-- Extract the folder path from the photo path
			-- TODO: Use the LrPathUtils
            local folderPath = photoPath:match("(.+)/[^/]+$")
			-- Extract the fileName from the photoPath
            local fileName = LrPathUtils.leafName(photoPath)
			-- Extract the base folder to use
			local folder = LrPathUtils.leafName(folderPath)
			-- Extract the base path defined in LR from the image path. ex. /Users/user/export/image.jpg to /Users/user/export
			local basePath = LrPathUtils.parent(pathOrMessage)
			-- Child = Join paths from the base path to the folder from the catalog
			local outputFolderPath = LrPathUtils.child(basePath, folder)
			-- Create the required directory
			LrFileUtils.createAllDirectories(outputFolderPath)
			-- Path where the image will finally go, in this case it will contain the original path + catalog folder + image name
			local outputFile = LrPathUtils.child(outputFolderPath, fileName)

			-- Move the file to the correct path
			local success, moveMessage = LrFileUtils.move(pathOrMessage, outputFile)

			if not success then
				local error = ""
				if moveMessage then
					error = moveMessage
				end
                LrDialogs.message("Error", "Failed to move file from " .. pathOrMessage .. " to " .. outputFile .. " reason: " .. moveMessage, "critical")
            end	
		end
		
	end

    if #failures > 0 then
		local message
		if #failures == 1 then
			message = LOC "$$$/CollectionExporter/ExportDialog/CollectionExporter/OneFailed=1 file failed to upload correctly."
		else
			message = LOC ( "$$$/CollectionExporter/ExportDialog/CollectionExporter/OneSomeFileFailed=^1 files failed to save it correctly.", #failures )
		end
		LrDialogs.message( message, table.concat( failures, "\n" ) )
	end



end