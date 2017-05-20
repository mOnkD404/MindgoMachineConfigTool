#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QTcpServer>
#include <QTcpSocket>
#include <QAbstractTableModel>
#include <QElapsedTimer>
#include <QThread>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    WorkerThread *workerThread = new WorkerThread(this);
          connect(workerThread, &WorkerThread::logInfo, this, &MainWindow::addLog);
          connect(workerThread, &WorkerThread::finished, workerThread, &QObject::deleteLater);
          workerThread->start();

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::addLog(const QString &log)
{
    ui->listWidget->addItem(log);
}


void WorkerThread::run()
{
    m_server = new QTcpServer();
    connect(m_server, &QTcpServer::newConnection, this, &WorkerThread::newConnection);
    m_server->listen(QHostAddress::Any, 20000);
}

void WorkerThread::newConnection()
{
    QTcpSocket *skt = m_server->nextPendingConnection();
    if(!skt->isOpen() || !skt->isValid())
        return;

    QDataStream stream;
    stream<<"client connectting ip:"<<skt->peerAddress()<<" port:"<<skt->peerPort();
    QString info;
    stream>>info;
    emit logInfo(info);

    QByteArray recvArray;
    while(skt->isOpen() && skt->isValid())
    {
        if(skt->waitForReadyRead(5000))
        {
            if (skt->bytesAvailable() > 0)
            {
                QByteArray array = skt->read(skt->bytesAvailable());
                qDebug()<<array.size()<<"data recv"<<array;
                recvArray.append(array);


                if (handleData(array))
                {
                    QThread::msleep(100);
                    skt->write(m_ackData);
                    skt->waitForBytesWritten();
                }
            }

        }
        else
        {
            break;
        }
    }
    skt->close();
    delete skt;
}

bool WorkerThread::handleData(const QByteArray& array)
{
    const char* command[5] = {
        "\x02\x00\x08\x80\x01",//load tip
        "\x02\x00\x08\x80\x02",//dump tip
        "\x02\x00\x12\x80\x03",//suction
        "\x02\x00\x10\x80\x04",//dispense
        "\x02\x00\x14\x80\x05"//mix

    };
    char ack[10] = "\x02\x00\x06\x00\x00\x00\x00\x00\x00";

    QString recvStr;
    QDataStream stream;
    if(memcmp(array.data(), command[0], 5) == 0)
    {
        stream<<"load tip command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[1], 5) == 0)
    {
        stream<<"dump tip command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[2], 5) == 0)
    {
        stream<<"suction command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[3], 5) == 0)
    {
        stream<<"despense command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[4], 5) == 0)
    {
        stream<<"mix command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);

    }
    else
    {
        return false;
    }
    stream>>recvStr;
    emit logInfo(recvStr);
    return true;
}
