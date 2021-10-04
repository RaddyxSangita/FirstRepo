CREATE TABLE `files` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
    `path` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
    `created` datetime NOT NULL,
    `modified` datetime NOT NULL,
    `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1 = Active, 0 = Inactive',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

Controller:
<?php
// src/Controller/HomeController.php

namespace App\Controller;

class HomeController extends AppController
{
    public function initialize(){
        parent::initialize();
        
        // Include the FlashComponent
        $this->loadComponent('Flash');
        
        // Load Files model
        $this->loadModel('Files');
        
        // Set the layout
        $this->layout = 'frontend';
    }
    
    public function index(){
        $uploadData = '';
        if ($this->request->is('post')) {
            if(!empty($this->request->data['file']['name'])){
                $fileName = $this->request->data['file']['name'];
                $uploadPath = 'uploads/files/';
                $uploadFile = $uploadPath.$fileName;
                if(move_uploaded_file($this->request->data['file']['tmp_name'],$uploadFile)){
                    $uploadData = $this->Files->newEntity();
                    $uploadData->name = $fileName;
                    $uploadData->path = $uploadPath;
                    $uploadData->created = date("Y-m-d H:i:s");
                    $uploadData->modified = date("Y-m-d H:i:s");
                    if ($this->Files->save($uploadData)) {
                        $this->Flash->success(__('File has been uploaded and inserted successfully.'));
                    }else{
                        $this->Flash->error(__('Unable to upload file, please try again.'));
                    }
                }else{
                    $this->Flash->error(__('Unable to upload file, please try again.'));
                }
            }else{
                $this->Flash->error(__('Please choose a file to upload.'));
            }
            
        }
        $this->set('uploadData', $uploadData);
        
        $files = $this->Files->find('all', ['order' => ['Files.created' => 'DESC']]);
        $filesRowNum = $files->count();
        $this->set('files',$files);
        $this->set('filesRowNum',$filesRowNum);
    }
    
}
Model:
<?php
// src/Model/Table/FilesTable.php

namespace App\Model\Table;

use Cake\ORM\Table;

class FilesTable extends Table
{
    public function initialize(array $config){
        $this->addBehavior('Timestamp');
    }
}

View Page:
<h1>Uploaded Files</h1>
<div class="content">
    <!-- Table -->
    <table class="table">
        <tr>
            <th width="5%">#</th>
            <th width="20%">File</th>
            <th width="12%">Upload Date</th>
        </tr>
        <?php if($filesRowNum > 0):$count = 0; foreach($files as $file): $count++;?>
        <tr>
            <td><?php echo $count; ?></td>
            <td><embed src="<?= $file->path.$file->name ?>" width="220px" height="150px"></td>
            <td><?php echo $file->created; ?></td>
        </tr>
        <?php endforeach; else:?>
        <tr><td colspan="3">No file(s) found......</td>
        <?php endif; ?>
    </table>
</div>
