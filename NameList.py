import os, argparse

def GenNameList(args):
	list = []
	if os.path.exists(args.Folder):
	    files = os.listdir(args.Folder)
	    for file in files:
	        m = os.path.join(args.Folder,file)
	        print(m)
	        if (os.path.isdir(m)):
	            h = os.path.split(m)
	            print(h[1])
	            list.append(h[1])
	fo = open(args.ListName, 'w')
	list = [line+"\n" for line in list]
	fo.writelines(list)
	fo.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--Folder", help="patients data folder", required=True)
    parser.add_argument("-ln", "--ListName", help="folder name list", required=True)
    args = parser.parse_args()
    GenNameList(args)