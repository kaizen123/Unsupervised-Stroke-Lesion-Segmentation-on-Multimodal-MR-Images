# coding=utf-8
import os, shutil, argparse
from glob import glob

Item = ['nodif.nii.gz', 'nodif_brain.nii.gz']

def InitFile(args):
    for subject in open(args.List, "r"):
        subject = subject.strip('\n')
        print("Subject: ", subject)
        prefixDir = args.MainFolder + subject + '*'
        dirs = glob(prefixDir)
        for dir in dirs:
            dirname = os.path.split(dir)[1]
            Newdir = args.NewFolder + dirname
            if not os.path.exists(Newdir):
                os.makedirs(Newdir)
                print("NewFolder: ", Newdir)
            for item in Item:
                src = dir + "\\" + item
                dst = Newdir + "\\" + item
                shutil.copyfile(src, dst)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--MainFolder", help="raw data folder", required=True)
    parser.add_argument("-l", "--List", help="Subject List", required=True)
    parser.add_argument("-n", "--NewFolder", help="New Folder", required=True)
    # parser.add_argument("-i", "--Item", help="Item(Name.Type) to copy", required=True)
    args = parser.parse_args()
    InitFile(args)