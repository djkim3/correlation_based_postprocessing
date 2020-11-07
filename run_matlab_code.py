import matlab.engine
import argparse
import sys

if __name__ == "__main__":
  def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-hash', '--hash_table', type=str, default='hash_table.mat', help='hash table with objects correlation score')
    parser.add_argument('-in', '--input_file', type=str, required=True, help='path to input annotation file')
    #parser.add_argument('-out1', '--sorted_annotation_file', type=str, default='sorted.txt', help='optional name of the output file with sorted confidences')
    #parser.add_argument('-out2', '--FPremoved_annotation_file', type=str, default='FPremoved.txt', help='optional name of the output file with FP removed using object correlations')
    

    
    args = parser.parse_args()

    if args.input_file is None:
      parser.print_help(sys.stderr)
      print("no input argument given")
      sys.exit(1)
      
    else:     
      input_file = args.input_file
      hash_table_path = args.hash_table
      
      eng = matlab.engine.start_matlab()
      
      eng.makeHashRemoveFP(input_file, hash_table_path, nargout=0)
      print("Postprocessing done!")
      eng.quit()
      
  main()