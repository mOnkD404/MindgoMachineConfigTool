#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTcpServer>
#include <QAbstractTableModel>

namespace Ui {
class MainWindow;
}

class TableModel;
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    bool handleData(const QByteArray& array);

public slots:
    void newConnection();

private:
    Ui::MainWindow *ui;

    QTcpServer m_server;
    TableModel* m_model;
    QByteArray m_ackData;
};

class TableModel: public QAbstractTableModel
{
public:

    void addRow(int index, char dat);
    Q_INVOKABLE virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    Q_INVOKABLE virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    Q_INVOKABLE virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

    QList<QPair<int,qint8> > m_data;
};

#endif // MAINWINDOW_H
