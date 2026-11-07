#pragma once

namespace tlbb {
// Shared by the launcher and the per-game panel, including task-table checks.
inline constexpr char checkboxStyle[] = R"css(
QCheckBox { spacing: 7px; }
QCheckBox::indicator, QTableView::indicator {
    width: 18px; height: 18px;
    border: 2px solid #526a7d; border-radius: 3px; background: white;
}
QCheckBox::indicator:hover, QTableView::indicator:hover { border-color: #08717b; }
QCheckBox::indicator:checked, QTableView::indicator:checked {
    background: #08717b; border-color: #08717b;
    image: url(:/tlbb/scripts/builtin/ui/checkmark.png);
}
QCheckBox::indicator:disabled, QTableView::indicator:disabled {
    background: #e6eaee; border-color: #a5b2bf;
}
QCheckBox::indicator:checked:disabled, QTableView::indicator:checked:disabled {
    background: #8d9fa4; border-color: #8d9fa4;
    image: url(:/tlbb/scripts/builtin/ui/checkmark.png);
}
)css";
}
