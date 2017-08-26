#ifndef COMMUNICATION_H
#define COMMUNICATION_H

#include "communication_global.h"

#include <QTcpSocket>
#include <QByteArray>
#include <QObject>
#include <QTimer>

#ifdef MINDGO_ALL_IN_ONE
class Communication:public QObject
#else
class COMMUNICATIONSHARED_EXPORT Communication
#endif
{
    Q_OBJECT
public:
    Communication(QObject* parent);

    bool connectToServer(const QString& host, quint16 port);
    void disconnect();
    void disconnectLater(int time = 5000);

    qint64 write(const QByteArray &byteArray);
    QByteArray readData(int msecs);

    bool connected(){ return m_socket.isOpen();}

protected:
    virtual void timerEvent(QTimerEvent* event);

private:
    QTcpSocket m_socket;
    int m_closeTimer;
};

#endif // COMMUNICATION_H
