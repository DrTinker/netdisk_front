import 'package:flutter/material.dart';

const userToken = "user_token";
const userEmail = "user_email";
const userPwd = "user_pwd";
const userStartDir = "user_start_dir";

const defaultSysPrefix = "test"; // 文件系统默认前缀

const taskTypeList = ['复制', '移动', '删除', '下载', '分享', '重命名'];
const taskIconList = [Icon(Icons.folder_copy), Icon(Icons.file_open), Icon(Icons.folder_delete), 
                      Icon(Icons.file_download), Icon(Icons.folder_shared), Icon(Icons.folder_special)];
const shareTaskTypeList = ['取消分享', '复制链接', '重新分享'];
const shareTaskIconList = [Icon(Icons.folder_copy), Icon(Icons.file_open), Icon(Icons.file_open)];

const transTaskTypeList = ['删除'];
const transTaskIconList = [Icon(Icons.folder_delete)];             

// 文件操作
const copyCode = 0;
const moveCode = 1;
const deleteCode = 2;
const downloadCode = 3;
const shareCode = 4;
const renameCode = 5;
const uploadCode = 6;

// 分享操作
const cancelCode = 0;
const linkCode = 1;
const createCode = 2;

// 传输操作
const tdeleteCode = 0;

const loginPassMap = {'/forget': true, '/signup': true,};

// 文件大小
const largeMark = 10 * 1024 *1024; // 超过10M启动分块上传
const MB = 1024 * 1024;
const KB = 1024;
const GB = 1024 * 1024 * 1024;

// 每页元素数量
const defaultPageSize = 20;

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

// 下载文件就绪
const readyWait = '0';
const readyDone = '1';
const readyAbort = '2';

// controller tag
const fcPerTag = "file_bus";
const ucPerTag = "user_bus";
const tcPerTag = "trans_bus";
const scPerTag = "share_bus";

// 音乐播放模式
const audioCycle = 0; // 列表循环
const audioLoop = 1; // 单曲循环
const audioRandom = 2; // 列表随机

// 文件分享list获取模式
const shareAll = 0;
const shareExpire = 1;
const shareOut = 2;

// 图片大小
const standardPicSize = 40.0;