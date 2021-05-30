var maxHeight;
var showButton, contentBox, footerPart;
var moving;

function ShowFoldRegion() {
    var h = contentBox.offsetHeight;
    function dmove() {
        if (h >= maxHeight) {
            contentBox.style.maxHeight = maxHeight + 'px';
            clearInterval(iIntervalId);
            moving = false;
        }
        else {
            moving = true;
            h += 20; // 设置层展开的速度
            contentBox.style.display = 'block';
            footerPart.style.display = "block";
            contentBox.style.maxHeight = h + 'px';
        }
    }
    if (!moving) {
        iIntervalId = setInterval(dmove, 3);
    }
}
function HideFoldRegion() {
    var h = contentBox.offsetHeight;
    function dmove() {
        if (h <= 0) {
            contentBox.style.display = 'none';
            footerPart.style.display = "none";
            clearInterval(iIntervalId);
            moving = false;
        }
        else {
            moving = true;
            h -= 20;// 设置层收缩的速度
            contentBox.style.maxHeight = h + 'px';
        }
    }
    if (!moving) {
        iIntervalId = setInterval(dmove, 3);
    }
}

// id 是标识区域唯一的标志，在代码里由 GUID 生成，
// maxh 是折叠内容的最大高度，超过时则显示滚动条
function memento_fold_show(id, maxh) {
    if(!moving)
    {
        maxHeight = maxh;
        contentBox = document.getElementById("memento_box_" + id);
        showButton = document.getElementById("memento_show_" + id);
        footerPart = document.getElementById("memento_footer_" + id);
        if (contentBox.style.display == "block") {
            HideFoldRegion();
            showButton.innerHTML = "展开";
        }
        else {
            ShowFoldRegion();
            showButton.innerHTML = "收缩";
        }
    }
}