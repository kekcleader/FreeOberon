## Oberon's Files.Mod - differences from POSIX style file APIs

Most operating systems provide file access in a similar and familiar manner:
 - A new file is initially created as an entry in a filesystem directory referencing an empty file. 
 - File writes add to this file though buffers that will be flushed when full and at file close. 
 - Following file close the file is inacccessible until reopened.

#### Why is a file *always* indexed in the filesystem directory? 

Before computers, files would be stored in filing cabinets for long term storage and retrieval, but they would also live independent of filing cabinets, for example in in-trays or out-trays, or loose on desks while being assembled.

A file outside the filing cabinet might be being in the process of updating and so in an incomplete or inconsistant state. A file in the filing cabinet might be considered complete and consistent.

#### Oberon Files.Mod behaviour

Oberons filesystem behaviour is arguably closer to pre-computer usage. Files can easily exist independent of the filesystem directory:

 - Files.New creates a Files.File object that is fully writeable (and readable) but which is not (yet) indexed in the the filesystem. 
 - Files.Register puts the files name into the filesystem directory.
 - Files.Delete takes the files name out of the filesystem directory.
 - Neither Register nor Delete affect the file content or access to it.
 - The files disk space will be recovered when there is neither a Files.File object referencing the file, nor is its file name present in the directory.

For example it would be possible for a program to create a new file (Files.New), and then repeatedly put it into the directory (Files.Register) and take it out of the directory (Files.Delete) while at all times the Files.File returned by Files.New remains valid and the content and connected riders are unaffected by the directory changes. 
 
#### Comparing the Posix and Oberon approaches to file creation.

On a real Oberon system, file access is independent of the file directory and the Oberon APIs directly reflect the system implementation. 

On a POSIX like system some Oberon APIs require implementation workarounds. This table illustrates Oberon behaviour by describing how it is implemented on top of a POSIX like filesystem.

|Oberon API|Oberon behaviour|C API|C behaviour|
|---|---|---|---|
|Files.New(name)|Creates a file handle (Files.File) but does not touch the disk.|fopen(name, "w")|Creates an empty file and returns a handle. The empty file is immediately visible to other processes.|
|Files.Set(rider,file,pos)|Creates a rider at a given file position. Multiple riders may be created on the same file at the same or different positions.|----|----|
|Files.WriteBytes(rider,bytes,len)|Buffers are allocated to store written data (current implementation is up to 4 buffers, each 4kb). <br>Until the buffers are full nothing is written to disk and no file is created in the OS|fwrite()|Data is written to a buffer up to a system dependant size, nothing is written to disk.|
|Files.WriteBytes beyond buffer size|Once more than 16kb has been written, Vishap Oberon creates a temporary file to back up least recently accessed buffers.|fwrite()...|Once the internal buffer is full it is written to the named disk file|
|Files.Register|If all data is still in buffers (no temp file has been created), an OS file is created using the name originally passed to Files.New. <br>If a temporary file had been created it is renamed to the name originally passed to Files.New. <br>All buffered data is flushed to the file.|(no equivalent)||
|Files.Delete|If there is no Files.File in the same program referencing the file then unlink/DeleteFile is called. <br>If there is a Files.File the OS file is renamed as a temporary file. <br>Any riders active on the file remain valid. <br>The file can be reregistered later.|unlink() or DeleteFile()|The file is marked for deletion and will be removed from the filesystem directory when no processes have it open. <br>Neither Windows nor Linux allow the file to be put back into the directory.|
|Files.Close|Any buffered data is flushed to disk. *The file object and all riders remain valid, data can still be read and written*.|close|Any buffered data is flushed to disk. The file handle is no longer valid for use.|

Note that the Oberon approach results naturally in files not being visible to other processes until the writer has written a complete set of data. 

On other systems one common workaround is to write to a temporary file, and then rename it to it's public name, taking care of course to create the temporary file on the same device/partition where it will be published. 

Another workaround is to use file locking to keep the file inaccessible until the full set of data is written, of course taking care to avoid deadlocks.


### More on the Vishap Oberon emulation of Oberon system file access.

Emulation of Oberon system behaviour is part of the Vishap Oberon run time system linked into each program. When multiple Oberon programs are running there are necessarily multiple run time systems running. 

#### Two programs writing to the same file

Each run time system provides Oberon like buffer management. For example, each run time system ensures that multiple riders based on the same file share the same file buffers, such that writes to one of the riders are immediately availble to all (suitably positioned) other riders. 

It is a limitation that this parallel read and write behaviour does not work accross multiple porgams. 

#### Deleting and re-registering files

Each run time system tracks deletes and registers to provide Oberon system behaviour, allowing a file to be registered, deleted, and re-registered as often as desired. (When the file is deleted, the run time system converts it back to a temporary file.)

It is a limitation that the run time system does not provide full Oberon behaviour when a file is opened that is also in use by another program, or for which there are other hard links.

#### Details

|Activity|Behaviour|
|---|---|
|Rider buffering|File decriptors and buffers are not shared between multiple instances of the runtime system, therefore if two separate programs call Files.Old on the same file, writes to a rider in one program will usually not be reflected by reads in another program. <br>Further if both programs are writing to parts of the file that fall in the same buffer area, data will likely be lost: the second program to flush its buffer will overwrite new data written by the program that flushed first. While this is expected behaviour for most operating systems, it is not Oberon behaviour.|
|Register and Delete|When an Oberon program program calls Files.Delete passing a filename for which there is a Files.File instance, its runtime system renames the file as a temporary file and records that it is unregistered. The file continues to be accessible by all programs that have it open. When the program that deleted it completes it will call unlink, causing the OS to actually remove it once no programs have it open. This much is valid Oberon system behaviour.<br>However only the runtime system of the program that deleted the file knows that it is now unregistered and can successfully register it again. Run time systems of other running Vishap Oberon programs still think the file is registered and will be unable to Register it themselves.|