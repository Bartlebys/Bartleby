//
//  BartlebysCommandsFacade.swift
//  bartleby
//
//  Created by Benoit Pereira da silva on 24/01/2016.
//  Copyright © 2016 Benoit Pereira da silva. All rights reserved.
//

import Foundation

struct BartlebysCommandFacade {


    static let args = Process.arguments

    let executableName = NSString(string: args.first!).pathComponents.last!
    let firstArgumentAfterExecutablePath: String? = (args.count >= 2) ? args[1] : nil

    func actOnArguments() {
        switch firstArgumentAfterExecutablePath {
        case nil:
           // self._expandBundle()
            print(self._noArgMessage())
            exit(EX_NOINPUT)
        case "-h"?, "-help"?, "h"?, "help"?:
            print(self._noArgMessage())
            exit(EX_USAGE)
        case "testTasks"?:
            graph_exec_completion_routine(TasksGroup.Priority.High, useRandomPause:false, numberOfSequTask:1000, testMode:GraphTestMode.Chained)
        default:
            // We want to propose the best verb candidate
            let reference=[
                "h", "help",
                "install",
                "create",
                "generate",
                "update"
            ]
            let bestCandidate=self.bestCandidate(firstArgumentAfterExecutablePath!, reference: reference)
            print("Hey ...\"bsync \(firstArgumentAfterExecutablePath!)\" is unexpected!")
            print("Did you mean:\"bsync \(bestCandidate)\"?")
            exit(EX__BASE)
        }
    }

    private func _expandBundle() {

        let phpTask=NSTask()
        if let path=BartlebysCommandFacade.args.first {
            phpTask.currentDirectoryPath=(path as NSString).stringByDeletingLastPathComponent
        }

        phpTask.launchPath="/usr/bin/php"

        let useZip="false"
        let packagePath="/Users/bpds/Documents/Entrepot/Git/Bartlebys/Distribution/Bundle.package"
        let expandPath="/Users/bpds/Documents/Entrepot/Git/Bartlebys/Distribution/Bundle-sources/"

        /*

         We do embed the Bundler code to be able to perform
         To regenerate you can call the command :

         php -f encodeForSwift.php args --source $BUNDLER_FOLDER_PATH/Bundler.php


         */
        let bundlerPHP="\n\n\nnamespace Bartleby;\n\nuse \\ZipArchive;\nuse \\Exception;\n\n// @todo\n// # crypto support\n// # VARIABLES INJECTION SUPPORT from a JSON mapping file.\n\nclass Bundler {\n\n  // METADATA Starts and Ends Tags\n  const BUNDLER_METADATA_STARTS = \"#BMS#->\";\n  // BETWEEN = The bundler metadate are JSON ENCODED\n  const BUNDLER_METADATA_ENDS = \"<-#BME#\\n\";\n\n  // METADATA KEYS\n  const BUNDLER_FILE_NAME_KEY = 'filename';\n  const BUNDLER_SIZE_KEY = 'size';\n  const BUNDLER_CHECKSUM_KEY = 'checksum';\n  const BUNDLER_RELATIVE_PATH_KEY = 'relativePath';\n\n  static private $VERBOSE = true;\n  static private $USE_ZIP = \(useZip);\n  static private $ENCODE_METADATA_TAGS = false;\n\n  /**\n * @var bool\n */\n  private $_userCommandLineMode = true;\n\n\n  /**\n * @var array\n */\n  private $_rawArguments = array();\n\n  /**\n * @var array\n */\n  private $_arguments = array();\n\n  /**\n * Bundler constructor.\n */\n  public function __construct() {\n  // The argument can also be defined from a boot php script\n  if (!isset($arguments)) {\n  // Server & commandline versatile support\n  if ($_SERVER ['argc'] == 0 || !defined('STDIN')) {\n // Server mode\n $this->_arguments = $_GET;\n $this->_userCommandLineMode = false;\n  } else {\n // Command line mode\n $rawArgs = $_SERVER ['argv'];\n array_shift($rawArgs); // shifts the commandline script file\n\n $nbOfArgs = count($rawArgs);\n\n if ($nbOfArgs > 0 && $rawArgs[0] == \"args\") {\n array_shift($rawArgs);\n $nbOfArgs = count($rawArgs);\n }\n\n if ($nbOfArgs % 2 == 0) {\n if ($rawArgs > 0) {\n for ($i = 0; $i < $nbOfArgs; $i = $i + 2) {\n   $flag = $rawArgs[$i];\n   $flag = str_replace('--', '', $flag);\n   $flag = str_replace('-', '', $flag);\n   $value = $rawArgs[$i + 1];\n   $this->_arguments[$flag] = $value;\n }\n }\n } else {\n throw new \\Exception('Arguments flag / value parity issue');\n }\n $this->_userCommandLineMode = true;\n\n  }\n\n  }\n  }\n\n  /**\n * This method can accept arguments from a commandline or by GET\n * \"source\n * @throws \\Exception\n */\n  function build() {\n\n  // Arguments?\n  if (array_key_exists('source', $this->_arguments)) {\n  $mapPath = $this->_arguments['source'];\n\n  $mapString = file_get_contents($mapPath);\n  $map = json_decode($mapString);\n\n  $parentFolder = dirname(realpath($mapPath)) . DIRECTORY_SEPARATOR;\n\n  $modules = $map->modules;\n  $distributionFolderPath = $map->distributionFolderPath;\n  $distributionPath = $map->distributionPath.isset($map->version)?$map->version:'';\n\n  foreach ($modules as $module) {\n $moduleSourcePath = $parentFolder . $module->path;\n /* @var array */\n $excludeFiles = $module->exclude;\n $destination = $parentFolder . $distributionFolderPath . basename($moduleSourcePath);\n $this->_copyFile($moduleSourcePath, $destination);\n  }\n\n  } else {\n  throw new \\Exception('You must provide a map');\n  }\n  }\n\n\n  /**\n * This method can accept arguments from a commandline or by GET\n * \"source\"\n * It returns a string encoded to be embedded in Swift\n * @throws \\Exception\n */\n  function encodeForSwift() {\n  // Arguments?\n  if (array_key_exists('source', $this->_arguments)) {\n  $path = $this->_arguments['source'];\n  $content = file_get_contents($path);\n  $content = str_replace('\n',\"\\n\",$content);\n  $content = str_replace('\n',\"\\n\",$content);\n  $content = str_replace('\\\\','\\\\\\\\',$content);\n  $content = str_replace(\"\\n\",'\\\\n',$content);\n  $content = str_replace(\"\\t\",'\\\\t',$content);\n  $content = str_replace(' ',' ',$content);\n  $content = str_replace('  ',' ',$content);\n  $content = str_replace('  ',' ',$content);\n  $content = str_replace(' ',' ',$content);\n  $content = str_replace(' ',' ',$content);\n  $content = str_replace('  ',' ',$content);\n  $content = str_replace('\"','\\\"',$content);\n  echo \"\\n\\n\".$content.\"\\n\\n\";\n  } else {\n  throw new \\Exception('You must provide a source');\n  }\n  }\n\n\n\n  /**\n * A simple wrapper to createBundledFolder.sh\n */\n  function createBundledFolder() {\n  echo shell_exec(__DIR__ . DIRECTORY_SEPARATOR . 'createBundled.sh');\n  }\n\n\n  /**\n * This method can accept arguments from a commandline or by GET\n * \"source\" , \"destination\"\n * Default source is set to dirname(__DIR__).'/Bundled/'\n * Default destination is set to dirname(__DIR__).'/Bundle.package';\n *\n * @throws \\Exception\n */\n  function pack() {\n  // Default\n  $directoryPath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'Bundled' . DIRECTORY_SEPARATOR;\n  $outputPath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'Bundle.package';\n  // Arguments?\n  if (array_key_exists('source', $this->_arguments)) {\n  $directoryPath = $this->_arguments['source'];\n  }\n  if (array_key_exists('destination', $this->_arguments)) {\n  $outputPath = $this->_arguments['destination'];\n  }\n  $this->_packFilesFromDirectory($directoryPath, $outputPath);\n  }\n\n  /**\n * This method can accept arguments from a commandline, by GET parameters or function arguments\n * \"source\" , \"destination\"\n * Default source is set to dirname(__DIR__).'/Bundle.package.zip'\n * Default destination is set to dirname(__DIR__).'/ExpandedBundle/'\n *\n * @param string|null $bundledFilePath\n * @param string|null $destinationFolderPath\n * @throws Exception\n */\n  function unPack($bundledFilePath=NULL,$destinationFolderPath=NULL) {\n  if (!isset($bundledFilePath)){\n  //Default\n  $bundledFilePath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'Bundle.package';\n  }\n  if (Bundler::$USE_ZIP) {\n  $bundledFilePath .= '.zip';\n  }\n  if (!isset($destinationFolderPath)){\n  //Default\n  $destinationFolderPath = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'Expanded' . DIRECTORY_SEPARATOR;\n  }\n\n  // Arguments?\n  if (array_key_exists('source', $this->_arguments)) {\n  $bundledFilePath = $this->_arguments['source'];\n  }\n  if (array_key_exists('destination', $this->_arguments)) {\n  $destinationFolderPath = $this->_arguments['destination'];\n  }\n  $this->_unPackFiles($bundledFilePath, $destinationFolderPath);\n  }\n\n  /***\n * The private implementation\n *\n * @param $directoryPath\n * @param $outputPath\n * @throws \\Exception\n */\n  private function _packFilesFromDirectory($directoryPath, $outputPath) {\n  if (!file_exists($directoryPath)) {\n  throw new \\Exception(\"Path do no exists\" . $directoryPath);\n  }\n  $fHandle = fopen($outputPath, \"wb\");\n  if ($fHandle === false) {\n  throw new \\Exception(\"Open destination handle Error \" . $outputPath);\n  }\n  $iterators = new \\RecursiveIteratorIterator(new \\RecursiveDirectoryIterator($directoryPath));\n  foreach ($iterators as $fileDetails) {\n  $exclusionList = ['.DS_Store'];\n  /* @var $fileDetails \\SplFileInfo */\n  $fileName = $fileDetails->getFilename();\n\n\n  $filePath = $fileDetails->getPathname();\n  $filesize = filesize($filePath);\n  $relativePath = str_replace($directoryPath, \"\", $filePath);\n  $extension = pathinfo($fileDetails->getPath());\n\n  if (in_array($fileName, $exclusionList)) {\n if (Bundler::$VERBOSE === true) {\n echo \"Skipping \" . $filePath . \"\\n\";\n }\n continue;\n  }\n\n  if (Bundler::$VERBOSE === true) {\n echo \"Packaging \" . $fileName . \"\\n\";\n echo $filePath . \"\\n\";\n  }\n\n  $isDir = $fileDetails->isDir();\n\n  if ($fileName != \"..\" &&\n $fileName != \".\"\n  ) {\n\n $readInFile = NULL;\n if (!$isDir) {\n $rHandle = fopen($filePath, \"rb\");\n if ($rHandle == false) {\n throw new \\Exception(\"Error open file to read from \" . $filePath);\n }\n $readInFile = fread($rHandle, $filesize);\n if ($readInFile == false) {\n throw new \\Exception(\"Error on reading file to read from \" . $filePath);\n }\n fclose($rHandle);\n }\n $checksum = 0;\n if (!$isDir) {\n $checksum = crc32($readInFile);\n }\n\n // Write the METADATA Array\n $metadataString = $this->_protectTag(Bundler::BUNDLER_METADATA_STARTS);\n $metadataArray = array(\n Bundler::BUNDLER_FILE_NAME_KEY => $fileName,\n Bundler::BUNDLER_CHECKSUM_KEY => $checksum,\n Bundler::BUNDLER_RELATIVE_PATH_KEY => $relativePath,\n Bundler::BUNDLER_SIZE_KEY => $filesize\n );\n $metadataJson = json_encode($metadataArray);\n $metadataString .= $metadataJson;\n $metadataString .= $this->_protectTag(Bundler::BUNDLER_METADATA_ENDS);\n if (fwrite($fHandle, $metadataString) === false) {\n throw new \\Exception(\"Error writing Bundler metadata for \");\n }\n\n // Write the The file Content\n if (!$isDir) {\n if (fwrite($fHandle, $readInFile) === false) {\n throw new \\Exception(\"Error writing binary data\");\n }\n }\n  }\n  }\n  fclose($fHandle);\n\n  if (Bundler::$USE_ZIP) {\n  if (file_exists($outputPath . '.zip')) {\n unlink($outputPath . '.zip');\n  }\n  $zip = new ZipArchive();\n  if ($zip->open($outputPath . '.zip', ZipArchive::CREATE) !== TRUE) {\n throw new \\Exception(\"ZipArchive was not able to open <$outputPath.zip>\\n\");\n  };\n  $zip->addFile($outputPath, basename($outputPath));\n  $zip->close();\n  unlink($outputPath);\n\n  }\n  }\n\n  private function _unPackFiles($fileToReadFrom, $fileDirectoryToWrite) {\n\n\n  if (Bundler::$USE_ZIP) {\n  $unzippedFilePath = str_replace(\".zip\", \"\", $fileToReadFrom);\n  $zip = new ZipArchive();\n  if ($zip->open($fileToReadFrom) !== TRUE) {\n throw new \\Exception(\"ZipArchive was not able to open <$fileToReadFrom>\\n\");\n  }\n  if (file_exists($unzippedFilePath)) {\n unlink($unzippedFilePath);\n  }\n\n  if ($zip->extractTo($unzippedFilePath) === true) {\n throw new \\Exception(\"ZipArchive was not able to extract <$fileToReadFrom>\\n\");\n  }\n  // use the unzipped file\n  $fileToReadFrom = $unzippedFilePath;\n  }\n\n  if (file_exists($fileDirectoryToWrite) === false) {\n  mkdir($fileDirectoryToWrite);\n  }\n\n  $rHandle = fopen($fileToReadFrom, \"rb\");\n  if ($rHandle == false) throw new \\Exception(\"Error opening file to read\");\n  while (!feof($rHandle)) {\n\n  $nextLine = fgets($rHandle); // read one line\n\n  if ($nextLine !== false) {\n $jsonString = str_replace($this->_protectTag(Bundler::BUNDLER_METADATA_STARTS), '', $nextLine);\n $jsonString = str_replace($this->_protectTag(Bundler::BUNDLER_METADATA_ENDS), '', $jsonString);\n $metadata = json_decode($jsonString, true);\n if (is_array($metadata)) {\n if (array_key_exists(Bundler::BUNDLER_FILE_NAME_KEY, $metadata) &&\n array_key_exists(Bundler::BUNDLER_RELATIVE_PATH_KEY, $metadata) &&\n array_key_exists(Bundler::BUNDLER_SIZE_KEY, $metadata) &&\n array_key_exists(Bundler::BUNDLER_CHECKSUM_KEY, $metadata)\n ) {\n $filename = $metadata[Bundler::BUNDLER_FILE_NAME_KEY];\n $relativePath = $metadata[Bundler::BUNDLER_RELATIVE_PATH_KEY];\n $filesize = $metadata[Bundler::BUNDLER_SIZE_KEY];\n $checksum = $metadata[Bundler::BUNDLER_CHECKSUM_KEY];\n\n $absolutePath = $fileDirectoryToWrite . $relativePath;\n\n if ($filesize === 0) {\n   // It is a folder\n   // Let's try to recreate the folder\n   mkdir($absolutePath);\n   continue;\n }\n\n $bytes = fread($rHandle, $filesize);\n if ($bytes === false) {\n   throw new \\Exception(\"Error reading bytes\");\n }\n\n $parentFolder = dirname($absolutePath);\n if (file_exists($parentFolder) == false) {\n   mkdir(dirname($absolutePath), 0777, true);\n }\n\n $fHandle = fopen($absolutePath, \"wb\");\n\n if (Bundler::$VERBOSE === true) {\n   echo \"Un-packing \" . $relativePath . \"\\n\";\n }\n\n if ($fHandle === false) {\n   throw new \\Exception(\"Error opening writing to file\");\n }\n\n // write the bytes\n if (fwrite($fHandle, $bytes) === false) {\n   throw new \\Exception(\"Error writing to file\");\n }\n fclose($fHandle);\n\n } else {\n throw new \\Exception(\"Unconsistent metadata\");\n }\n } else {\n throw new \\Exception(\"Metadata extraction\");\n }\n $absolutePath = NULL;\n  }\n\n  }\n  fclose($rHandle);\n  if (Bundler::$USE_ZIP) {\n  unlink($unzippedFilePath);\n  }\n  }\n\n  // TAGS \n  \n  \n  private function _protectTag($tag) {\n  if (Bundler::$ENCODE_METADATA_TAGS) {\n  return md5($tag);\n  } else {\n  return $tag;\n  }\n  }\n\n  private function _encodeTags($string) {\n  $string = str_replace(Bundler::BUNDLER_METADATA_STARTS, _protectTag(Bundler::BUNDLER_METADATA_STARTS), $string);\n  $string = str_replace(Bundler::BUNDLER_METADATA_ENDS, _protectTag(Bundler::BUNDLER_METADATA_ENDS), $string);\n  return $string;\n  }\n\n\n  private function _decodeTags($string) {\n  $string = str_replace($this->_protectTag(Bundler::BUNDLER_METADATA_STARTS), Bundler::BUNDLER_METADATA_STARTS, $string);\n  $string = str_replace($this->_protectTag(Bundler::BUNDLER_METADATA_ENDS), Bundler::BUNDLER_METADATA_ENDS, $string);\n  return $string;\n  }\n\n  \n  ////////////////////\n  // FILE UTILITIES\n  ////////////////////\n  \n  \n  private function _copyFile($filePath, $destination) {\n  @mkdir(dirname($destination));\n  try {\n  copy($filePath, $destination);\n  } catch (\\Exception $e) {\n  echo('error on copy ' . $filePath . '->' . $destination);\n  }\n  }\n\n  private function _copyPath($folderPath,$destination,$relativePath=NULL,$exclusionList=NULL){\n  \n  }\n\n  private function _removePath($path) {\n  if (is_dir($path)) {\n  $files = scandir($path);\n  foreach ($files as $file)\n if ($file != \".\" && $file != \"..\") $this->_removePath($path.DIRECTORY_SEPARATOR.$file);\n  rmdir($path);\n  }\n  else if (file_exists($path)) unlink($path);\n  }\n}\n\n"


        let invokeBundlerUnPack="$bundler=new Bundler(); $bundler->unPack('\(packagePath)','\(expandPath)');"
        phpTask.arguments=["-r", bundlerPHP+invokeBundlerUnPack]


        phpTask.launch()
        phpTask.waitUntilExit()
    }


    private func _noArgMessage() -> String {
        var s=""
        s += "Bartleby's CLI"
        s += "\nCreated by Benoit Pereira da Silva"
        s += "\nhttps://pereira-da-silva.com for Chaosmos SAS"
        s += "\n"
        s += "\nvalid calls are S.V.O sentences like:\"bsync <verb> [options]\""
        s += "\nAvailable verbs:"
        s += "\n"
        s += "\n\t\(executableName) install -m <Manifest FilePath>"
        s += "\n\t\(executableName) create <Manifest FilePath>"
        s += "\n\t\(executableName) generate <Manifest FilePath>"
        s += "\n\t\(executableName) update <Manifest FilePath>"
        s += "\n"
        s += "\nRemember that you can call help for each verb"
        s += "\n"
        s += "\n\te.g:\t\"bsync synchronize help\""
        s += "\n\te.g:\t\"bsync snapshoot help\""
        s += "\n"
        return s
    }

    // MARK: levenshtein distance
    // https://en.wikipedia.org/wiki/Levenshtein_distance

    private func bestCandidate(string: String, reference: [String]) -> String {
        var selectedCandidate=string
        var minDistance: Int=Int.max
        for candidate in reference {
            let distance=self.levenshtein(string, candidate)
            if distance<minDistance {
                minDistance=distance
                selectedCandidate=candidate
            }
        }
        return selectedCandidate
    }

    private func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], combine: {$0 < $1 ? $0 : $1})
    }

    private class Array2D {
        var cols: Int, rows: Int
        var matrix: [Int]

        init(cols: Int, rows: Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(count:cols*rows, repeatedValue:0)
        }

        subscript(col: Int, row: Int) -> Int {
            get {
                return matrix[cols * row + col]
            }
            set {
                matrix[cols*row+col] = newValue
            }
        }

        func colCount() -> Int {
            return self.cols
        }

        func rowCount() -> Int {
            return self.rows
        }
    }

    private func levenshtein(aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)

        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        for i in 1...a.count {
            dist[i, 0] = i
        }

        for j in 1...b.count {
            dist[0, j] = j
        }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i, j] = min(
                        dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        return dist[a.count, b.count]
    }
}
