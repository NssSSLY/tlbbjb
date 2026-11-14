#pragma once
#include <QDir>
#include <QFile>
#include <QPainter>
#include <QPainterPath>
#include <QPen>
#include <QPixmap>
#include <QStandardPaths>
#include <QString>

namespace tlbb {
// The tick is drawn here instead of shipped as a file: the installed layout keeps scripts on disk,
// so a resource path to a packaged image never resolved and checked boxes showed a solid block.
inline QString checkmarkImage(){
    static QString path;
    if(!path.isEmpty())return path;
    QString dir=QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/tlbb-ui";
    QDir().mkpath(dir);
    const QString file=dir+"/checkmark-v2.png";
    if(!QFile::exists(file)){
        QPixmap tick(32,32);tick.fill(Qt::transparent);
        QPainter p(&tick);p.setRenderHint(QPainter::Antialiasing);
        p.setPen(QPen(Qt::white,4.2,Qt::SolidLine,Qt::RoundCap,Qt::RoundJoin));
        QPainterPath mark;mark.moveTo(7,16.5);mark.lineTo(13.5,23);mark.lineTo(25,9.5);p.drawPath(mark);p.end();
        tick.save(file,"PNG");
    }
    path=QDir::fromNativeSeparators(file);return path;
}
// Shared by the launcher and the per-game panel, including task-table checks.
inline QString checkboxStyleSheet(){
    return QString(R"css(
QCheckBox { spacing: 6px; background: transparent; }
QCheckBox::indicator, QTableView::indicator {
    width: 14px; height: 14px;
    border: 1px solid #9aa9b8; border-radius: 3px; background: white;
}
QCheckBox::indicator:hover, QTableView::indicator:hover { border-color: #0b7f8a; }
QCheckBox::indicator:checked, QTableView::indicator:checked {
    background: #0b7f8a; border-color: #0b7f8a; image: url(%1);
}
QCheckBox::indicator:disabled, QTableView::indicator:disabled { background: #eef1f4; border-color: #c3ccd5; }
QCheckBox::indicator:checked:disabled, QTableView::indicator:checked:disabled {
    background: #a9b6bb; border-color: #a9b6bb; image: url(%1);
}
)css").arg(checkmarkImage());
}
}
