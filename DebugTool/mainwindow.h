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
    WorkerObject(QObject* parent = NULL):QObject(parent) {}

signals:
    void logInfo(const QString& str);

public slots:
    void startServer();
    void newConnection();

protected:
    bool handleData(const QByteArray& array);

private:
    QTcpServer *m_server;
    QByteArray m_ackData;
};
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

public slots:
    void addLog(const QString& );

private:
    Ui::MainWindow *ui;
    QThread m_worker;

};


#endif // MAINWINDOW_H
