'''
Created on 03-Sep-2020

@author: joshi
'''



class pos_func() :
    
    '''
    '''
    def __init__(self,pn7462):
        '''  '''
        self.pn7462= pn7462
        
        
    def get_config_cmd (self):
        ''' '''
        error,out,len = self.pn7462.read_write([0x00,0x05,0x00,0x00,0x00,0xFF,0xF8,0x00,0x00,0x00])
        return error,out,len
        
    
      
        
    def enable_polling_cmd(self):
        ''' '''
        error,out,len = self.pn7462.read_write([0x00,0x05,0x00,0x00,0x00,0xFF,0xF8,0x07,0x01,0x00])
        return error,out,len
    
       
        
    def get_status_cmd(self):
        '''   '''
        error,out,len = self.pn7462.read_write([0x00,0x05,0x00,0x00,0x00,0xFF,0xF8,0x02,0x00,0x00])
        return error,out,len
   
       
    def get_uid(self):
        '''  '''
        error,out,len = self.pn7462.read_write([0x00,0x05,0x00,0x00,0x00,0xFF,0xF8,0x0C,0x00,0x00])
        return error,out,len
    
        
    def get_atr(self):
        ''' '''
        error,out,len = self.pn7462.read_write([0x00,0x05,0x00,0x00,0x00,0xFF,0xF8,0x03,0x00,0x00])
        return error,out,len
    
       
    def sel_PPSC_command(self):
        ''' ''' 
        
    def sel_appl_cmd(self):
        '''  '''
    def deactivate_card(self):
        '''  '''
        error,out,len = self.pn7462.read_write([0x00,0x05,0x00,0x00,0x00,0xFF,0xF8,0x04,0x00,0x00])
        return error,out,len
        
        
    