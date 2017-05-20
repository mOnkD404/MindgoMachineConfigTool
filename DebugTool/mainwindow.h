#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTcpServer>
#include <QAbstractTableModel>
#include <QThread>

namespace Ui {
class MainWindow;
}

class WorkerThread : public QThread
{
    Q_OBJECT
public:
    WorkerThread(QObject* parent = NULL):QThread(parent) {}
    virtual void run() ;

signals:
    void logInfo(const QString& str);

public slots:
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

};


#endif // MAINWINDOW_H
