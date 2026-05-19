-- Auto-forward every stable study so radiology images reach Satu Sehat.
-- Layered delivery:
--   1) C-STORE the whole study to the DICOM Router modality (DCMROUTER),
--      which uploads the DICOM pixels to Satu Sehat and creates ImagingStudy.
--   2) Notify worklist-web so it can reconcile/record the ImagingStudy and
--      act as a metadata fallback if the router callback never arrives.
-- Both calls are wrapped in pcall so one failing path never blocks the other.

function OnStableStudy(studyId, tags, metadata)
   local okStore, errStore = pcall(function()
      RestApiPost('/modalities/DCMROUTER/store', studyId)
   end)
   if not okStore then
      print('OnStableStudy: forward to DCMROUTER failed for study '
            .. studyId .. ': ' .. tostring(errStore))
   end

   local payload = '{"ChangeType":"StableStudy","ID":"' .. studyId
                   .. '","ResourceType":"Study"}'
   local okNotify, errNotify = pcall(function()
      HttpPost('http://worklist-web:8000/api/orthanc-webhook/', payload)
   end)
   if not okNotify then
      print('OnStableStudy: notify worklist-web failed for study '
            .. studyId .. ': ' .. tostring(errNotify))
   end
end
