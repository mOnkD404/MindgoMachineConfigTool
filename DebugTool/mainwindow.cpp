#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QTcpServer>
#include <QTcpSocket>
#include <QAbstractTableModel>
#include <QElapsedTimer>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    connect(&m_server, &QTcpServer::newConnection, this, &MainWindow::newConnection);
    m_server.listen(QHostAddress::Any, 20000);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::newConnection()
{
    QTcpSocket *skt = m_server.nextPendingConnection();
    if(!skt->isOpen())
        return;

    qDebug()<<"client connectting ip:"<<skt->peerAddress()<<" port:"<<skt->peerPort();

    QByteArray recvArray;
    while(skt->isOpen())
    {
        skt->waitForReadyRead();

        if (skt->bytesAvailable() > 0)
        {
            QByteArray array = skt->read(skt->bytesAvailable());
            qDebug()<<array.size()<<"data recv"<<array;
            recvArray.append(array);

            if (handleData(array))
            {
                skt->write(m_ackData);
                skt->waitForBytesWritten();
            }
        }
    }

}

bool MainWindow::handleData(const QByteArray& array)
{
    const char* command[5] = {
        "\x02\x00\x08\x80\x01",//load tip
        "\x02\x00\x08\x80\x02",//dump tip
        "\x02\x00\x12\x80\x03",//suction
        "\x02\x00\x10\x80\x04",//dispense
        "\x02\x00\x14\x80\x05"//mix

    };
    char ack[10] = "\x02\x00\x06\x00\x00\x00\x00\x00\x00";

    if(memcmp(array.data(), command[0], 5) == 0)
    {
        qDebug()<<"load tip command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,6);
    }
    else if(memcmp(array.data(), command[1], 5) == 0)
    {

        qDebug()<<"dump tip command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,6);
    }
    else if(memcmp(array.data(), command[2], 5) == 0)
    {

        qDebug()<<"suction command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,6);
    }
    else if(memcmp(array.data(), command[3], 5) == 0)
    {

        qDebug()<<"despense command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,6);
    }
    else if(memcmp(array.data(), command[4], 5) == 0)
    {

        qDebug()<<"mix command recv"<<array;

        memcpy(ack+3, array.data()+3, 4);
        m_ackData = QByteArray(ack,6);
    }
}


int TableModel::rowCount(const QModelIndex &parent) const
{
    return m_data.size();
}
int TableModel::columnCount(const QModelIndex &parent) const
{
    return 2;
}
QVariant TableModel::data(const QModelIndex &index, int role) const
{
    if(role == Qt::DisplayRole)
    {
        if(index.column() == 0)
        {
            return QVariant::fromValue(m_data.at(index.row()).first);
        }
        if(index.column() == 1)
        {
            return QVariant::fromValue(m_data.at(index.row()).second);
        }
    }
    return QVariant();
}
void TableModel::addRow(int index, char dat)
{
    m_data.append(qMakePair(index, dat));
    while(m_data.size() > 100)
    {
        m_data.pop_front();
    }
}
