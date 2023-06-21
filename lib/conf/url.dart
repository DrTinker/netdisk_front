const baseUrl = "http://192.168.2.6:8081";

const loginUrl = "$baseUrl/user/login";
const fileInfoUrl = "$baseUrl/object/list";
const mkDirUrl = "$baseUrl/object/mkdir";
const copyUrl = "$baseUrl/object/batch/copy";
const moveUrl = "$baseUrl/object/batch/move";
const deleteUrl = "$baseUrl/object/batch/delete";
const renameUrl = "$baseUrl/object/rename";

const uploadUrl = "$baseUrl/object/upload/total";
const initUploadPartUrl = "$baseUrl/upload_part/init";
const uploadPartUrl = "$baseUrl/upload_part/upload";
const completeUploadPartUrl = "$baseUrl/upload_part/complete";