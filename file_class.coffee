class File extends FileSystemItemAbstract

  start_watching: ->
    return if @watch is false or _.include(@watched_list, @path)
    console.log 'File::start_watching'.inverse + @options.path.magenta if @options.debug

    @watched_list.push @path
    if @fast_watch
      @file_watchers.push @fileWatcher = fs.watch @path, @watchHandler
    else
      fs.watchFile @path, @watchHandler


module.exports = File
