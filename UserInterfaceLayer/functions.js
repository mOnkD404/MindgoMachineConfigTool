.pragma library

function decodeError(errCode){
    var retVal;
    switch(parseInt(errCode)){
    case 0x1001:
        retVal = 'X轴定位失败';
        break;
    case 0x1002:
        retVal = 'Y轴定位失败';
        break;
    case 0x1003:
        retVal = 'Z轴定位失败';
        break;
    case 0x1004:
        retVal = 'U轴定位失败';
        break;
    case 0x2001:
        retVal = 'XY轴超限';
        break;
    case 0x2002:
        retVal = '装载力过大';
        break;
    case 0x2003:
        retVal = '装载力过小';
        break;
    case 0x3001:
        retVal = '手动急停按下';
        break;
    default:
        break;
    }
    return retVal;
}

function isGroupBegin(name){
    return name.match(/.*分组\[.*\]/);
}

function isGroupEnd(name){
    return name.match(/.*分组结束/);
}

function isLogicalCommand(name){
    var ret = false;
    switch(name){
    case "等待时间":
    case "循环":
    case "循环结束":
        ret = true;
        break;
    default: break;
    }
    return ret;
}
