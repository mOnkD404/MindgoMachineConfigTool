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
    ui->lineEdit->setText("200");

    WorkerObject *workerObj = new WorkerObject(NULL);
    workerObj->moveToThread(&m_worker);
    connect(workerObj, &WorkerObject::logInfo, this, &MainWindow::addLog);
    connect(this, &MainWindow::setSleepTime, workerObj, &WorkerObject::sleepTimeChanged, Qt::DirectConnection);
    connect(&m_worker, &QThread::finished, workerObj, &QObject::deleteLater);
    connect(&m_worker, &QThread::started, workerObj, &WorkerObject::startServer);

    m_worker.start();

}

MainWindow::~MainWindow()
{
    m_worker.quit();
    m_worker.wait();
    delete ui;
}

void MainWindow::addLog(const QString &log)
{
    ui->listWidget->addItem(log);
    ui->listWidget->setCurrentRow(ui->listWidget->count() - 1);
}


void WorkerObject::startServer()
{
    m_server = new QTcpServer();
    connect(m_server, &QTcpServer::newConnection, this, &WorkerObject::newConnection);
    m_server->listen(QHostAddress::Any, 20000);
}

void WorkerObject::newConnection()
{
    QTcpSocket *skt = m_server->nextPendingConnection();
    if(!skt->isOpen() || !skt->isValid())
        return;

    QString info;
    info += "client connectting ip:";
    info += skt->peerAddress().toString();
    info += " port:";
    info += QString::number(skt->peerPort());
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
                    QThread::msleep(m_sleepTime);
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

bool WorkerObject::handleData(const QByteArray& array)
{
    const char* command[] = {
        "\x02\x00\x0c\x80\x01",//load tip
        "\x02\x00\x0c\x80\x02",//dump tip
        "\x02\x00\x16\x80\x03",//suction
        "\x02\x00\x16\x80\x04",//dispense
        "\x02\x00\x1c\x80\x05",//mix
        "\x02\x00\x0A\x80\x06",//magnetic sep
        "\x02\x00\x0A\x81\x01",//rel
        "\x02\x00\x0A\x81\x02",//abs
        "\x02\x00\x06\x81\x03",//reset
    };
    char ack[10] = "\x02\x00\x06\x00\x00\x00\x00\x00\x00";

    QString recvStr;
    QTextStream dataStream(&recvStr, QIODevice::ReadWrite);
    if(memcmp(array.data(), command[0], 5) == 0)
    {
        dataStream<<"load tip command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[1], 5) == 0)
    {
        dataStream<<"dump tip command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[2], 5) == 0)
    {
        dataStream<<"suction command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[3], 5) == 0)
    {
        dataStream<<"despense command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[4], 5) == 0)
    {
        dataStream<<"mix command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
        m_ackData[8] = 1;
    }
    else if(memcmp(array.data(), command[5], 5) == 0)
    {
        dataStream<<"magnetic sep command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[6], 5) == 0)
    {
        dataStream<<"REL command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[7], 5) == 0)
    {
        dataStream<<"ABS command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else if(memcmp(array.data(), command[8], 5) == 0)
    {
        dataStream<<"reset command recv";

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,9);
    }
    else
    {
        return false;
    }
    foreach(const char ch, array)
    {
        dataStream<<" 0x";
        dataStream.setFieldWidth(2);
        dataStream.setPadChar('0');
        dataStream<<hex<<(quint8)ch;
    }
    dataStream.flush();

    emit logInfo(recvStr);
    return true;
}

void WorkerObject::sleepTimeChanged(int time)
{
    m_sleepTime = time;
}

void MainWindow::on_lineEdit_editingFinished()
{
    int sleepTime = ui->lineEdit->text().toInt();
    emit setSleepTime(sleepTime);
}

void MainWindow::on_lineEdit_returnPressed()
{

}
