const picFilter = ['jpg', 'jpeg', 'png', 'gif'];

// FLV 、AVI、MOV、MP4、WMV
const videoFilter = ['mp4', 'flv', 'avi', 'mov', 'wmv'];

// MP3，WMA，WAV，APE，FLAC，OGG，AAC
const audioFilter = ['mp3', 'wma', 'm4a' ,'wav', 'ape', 'flac', 'ogg', 'aac'];

// rar、zip、arj、tar
const packFilter = ['rar', 'zip', 'arj', 'tar', 'gz'];

// execel ppt doc docx md txt
const docFilter = ['excel', 'ppt', 'doc', 'docx', 'md', 'txt', 'pdf'];

const otherFilter = ['sql', 'py', 'java', 'go', 'dart'];

const randomPicList = [
  'assets/random/audio.jpg',
  'assets/random/dunyong2.jpg',
  'assets/random/dunyong3.jpg',
  'assets/random/nier.jpg',
  'assets/random/miku3.png',
  'assets/random/qq.jpg'
];

const iconMap = {'folder': 'assets/icons/folder.png', 
// 图片
'jpg': 'assets/icons/pic.png', 
'jpeg': 'assets/icons/pic.png', 
'png': 'assets/icons/pic.png', 
'gif': 'assets/icons/gif.png', 
// 视频
'mp4': 'assets/icons/video.png', 
'flv': 'assets/icons/video.png', 
'avi': 'assets/icons/video.png', 
'mov': 'assets/icons/video.png', 
'wmv': 'assets/icons/video.png', 
// 音频 'mp3', 'wma', 'm4a' ,'wav', 'ape', 'flac', 'ogg', 'aac'
'mp3': 'assets/icons/music.png', 
'wma': 'assets/icons/music.png', 
'm4a': 'assets/icons/music.png', 
'wav': 'assets/icons/music.png', 
'ape': 'assets/icons/music.png', 
'flac': 'assets/icons/music.png', 
'aac': 'assets/icons/music.png', 
'ogg': 'assets/icons/music.png', 
// 压缩包 rar zip arj tar
'rar': 'assets/icons/zip.png', 
'zip': 'assets/icons/zip.png', 
'arj': 'assets/icons/zip.png', 
'tar': 'assets/icons/zip.png', 
// 文档 'excel', 'ppt', 'doc', 'docx', 'md', 'txt'
'excel': 'assets/icons/excel.png', 
'ppt': 'assets/icons/ppt.png', 
'doc': 'assets/icons/doc.png', 
'docx': 'assets/icons/doc.png', 
'md': 'assets/icons/md.png', 
'pdf': 'assets/icons/pdf.png', 
'txt': 'assets/icons/txt.png', 
// 代码 'sql', 'py', 'java', 'go', 'dart'
'sql': 'assets/icons/code.png', 
'py': 'assets/icons/code.png', 
'java': 'assets/icons/code.png', 
'go': 'assets/icons/code.png', 
'dart': 'assets/icons/code.png', 
'c': 'assets/icons/code.png', 
'cpp': 'assets/icons/code.png', 
};