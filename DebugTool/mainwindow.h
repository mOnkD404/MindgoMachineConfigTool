#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTcpServer>
#include <QAbstractTableModel>
#include <QThread>

namespace Ui {
class MainWindow;
}

class WorkerObject : public QObject
{
    Q_OBJECT
public:
    WorkerObject(QObject* parent = NULL):QObject(parent), m_sleepTime(200) {}

signals:
    void logInfo(const QString& str);

public slots:
    void startServer();
    void newConnection();
    void sleepTimeChanged(int time);

protected:
    bool handleData(const QByteArray& array);

private:
    QTcpServer *m_server;
    QByteArray m_ackData;
    int m_sleepTime;
};
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

signals:
    void setSleepTime(int time);
public slots:
    void addLog(const QString& );

private slots:
    void on_lineEdit_editingFinished();

    void on_lineEdit_returnPressed();

private:
    Ui::MainWindow *ui;
    QThread m_worker;
};


#endif // MAINWINDOW_H
