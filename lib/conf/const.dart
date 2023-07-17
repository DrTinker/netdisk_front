import 'package:flutter/material.dart';

const userToken = "user_token";
const userInfo = "user_info";
const userStartDir = "user_start_dir";

const taskTypeList = ['复制', '移动', '删除', '下载', '分享', '重命名'];
const taskIconList = [Icon(Icons.folder_copy), Icon(Icons.file_open), Icon(Icons.folder_delete), 
                      Icon(Icons.file_download), Icon(Icons.folder_shared), Icon(Icons.folder_special)];
const copyCode = 0;
const moveCode = 1;
const deleteCode = 2;
const downloadCode = 3;
const shareCode = 4;
const renameCode = 5;
const uploadCode = 6;

const iconMap = {'folder': 'assets/icons/folder.png'};
const loginPassMap = {'/forget': true, '/signup': true, '/login': true};

// 文件大小
const largeMark = 2 * 1024 *1024; // 超过5M启动分块上传
const MB = 1024 * 1024;
const KB = 1024;
const GB = 1024 * 1024 * 1024;

// 文件传输
const uploadFlag = 0;
const downloadFlag = 1;
const transProcess = 0;
const transSuccess = 1;
const transFail = 2;
// process 下细分4个状态
const processWait = 0;
const processRunning = 1;
const processSuspend = 2;
const processFinish = 3;