import 'package:file_selector/file_selector.dart';

const picTypeGroup = XTypeGroup(label: 'pic', extensions: [
  'jpg',
  'jpeg',
  'png',
  'gif',
]);
const picFilter = [
  'jpg',
  'jpeg',
  'png',
  'gif',
];

// FLV 、AVI、MOV、MP4、WMV
const videoTypeGroup =
    XTypeGroup(label: 'video', extensions: ['mp4', 'flv', 'avi', 'mov', 'wmv']);
const videoFilter = ['mp4', 'flv', 'avi', 'mov', 'wmv'];

// MP3，WMA，WAV，APE，FLAC，OGG，AAC
const audioTypeGroup = XTypeGroup(
    label: 'audio',
    extensions: ['mp3', 'wma', 'wav', 'ape', 'flac', 'ogg', 'aac']);
const audioFilter = ['mp3', 'wma', 'wav', 'ape', 'flac', 'ogg', 'aac'];

// rar、zip、arj、tar
const packTypeGroup =
    XTypeGroup(label: 'pack', extensions: ['rar', 'zip', 'arj', 'tar', 'gz']);
const packFilter = ['rar', 'zip', 'arj', 'tar', 'gz'];

// execel ppt doc docx md txt
const docTypeGroup = XTypeGroup(
    label: 'doc', extensions: ['execel', 'ppt', 'doc', 'docx', 'md', 'txt']);
const docFilter = ['execel', 'ppt', 'doc', 'docx', 'md', 'txt'];

const otherTypeGroup = XTypeGroup(label: 'other');
const otherFilter = ['sql', 'py', 'java', 'go', 'dart'];
