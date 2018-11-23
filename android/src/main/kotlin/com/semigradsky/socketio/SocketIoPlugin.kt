package com.semigradsky.socketio

import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import java.util.logging.Logger

typealias InstanceId = String
typealias ListenerId = String

class SocketIoPlugin private constructor(
  registrar: Registrar,
  instanceId: InstanceId,
  uri: String
) {
  companion object {
    private const val CHANNEL_NAME = "semigradsky.com/socket.io"

    @JvmStatic
    private val logger = Logger.getLogger("Socket.IO Plugin")

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
      channel.setMethodCallHandler { call: MethodCall, result: Result ->
        when (call.method) {
          "createNewInstance" -> {
            val uri = call.argument<String>("uri") as String
            val instanceId = UUID.randomUUID().toString()
            SocketIoPlugin(registrar, instanceId, uri)
            result.success(instanceId)
          }
          else -> result.notImplemented()
        }
      }
    }
  }

  private val methodChannel: MethodChannel = MethodChannel(
    registrar.messenger(),
    "$CHANNEL_NAME/$instanceId"
  )

  private val socket: Socket = IO.socket(uri)
  private val listeners = mutableMapOf<ListenerId, Emitter.Listener>()

  init {
    methodChannel.setMethodCallHandler({ call: MethodCall, result: Result ->
      when (call.method) {
        "connect" -> {
          connect()
          result.success(null)
        }
        "on" -> {
          val event = call.argument<String>("event") as String
          val listenerId = on(event)
          result.success(listenerId)
        }
        "off" -> {
          val event = call.argument<String>("event") as String
          val listenerId = call.argument<ListenerId>("listenerId") as ListenerId
          off(event, listenerId)
          result.success(null)
        }
        "emit" -> {
          val event = call.argument<String>("event") as String
          val arguments = call.argument<List<Any>>("arguments") as List<Any>
          emit(event, arguments)
          result.success(null)
        }
        "isConnected" -> {
          val isConnected = socket.connected()
          result.success(isConnected)
        }
        "id" -> {
          val id = socket.id()
          result.success(id)
        }
        else -> result.notImplemented()
      }
    })
  }

  private fun connect() {
    socket.connect()
  }

  private fun on(event: String): ListenerId {
    val listenerId = UUID.randomUUID().toString()
    val listener = Emitter.Listener({ it ->
      val arguments = it.toList().map { argument ->
        when (argument) {
          is JSONArray -> return@map argument.toString()
          is JSONObject -> return@map argument.toString()
          is Throwable -> {
            return@map Log.getStackTraceString(argument)
          }
          else -> return@map argument
        }
      }
      methodChannel.invokeMethod("handleData", mapOf(
        "event" to event,
        "arguments" to arguments
      ))
    })
    listeners[listenerId] = listener
    socket.on(event, listener)
    return listenerId
  }

  private fun off(event: String, listenerId: ListenerId) {
    val listener = listeners[listenerId]
    socket.off(event, listener)
    listeners.remove(listenerId)
  }

  private fun emit(event: String, rawArguments: List<Any>) {
    val arguments = rawArguments.map { argument ->
      when (argument) {
        is List<*> -> return@map JSONArray(argument)
        is Map<*, *> -> return@map JSONObject(argument)
        else -> return@map argument
      }
    }
    socket.emit(event, *arguments.toTypedArray())
  }
}