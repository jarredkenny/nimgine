import deques
import types

proc newLogger(): Logger =
  result = Logger(level: LogLevel.Info, queue: initDeque[string]())

proc newLogger*(level: LogLevel): Logger =
  result = Logger(level: level, queue: initDeque[string]())

proc log*(logger: Logger, level: LogLevel, line: string) =
  logger.queue.addFirst(line)

proc log*(logger: Logger, line: string) =
  log(logger, LogLevel.Info, line)

iterator drain*(logger: Logger): string =
  while len(logger.queue) > 0:
    yield logger.queue.popLast()