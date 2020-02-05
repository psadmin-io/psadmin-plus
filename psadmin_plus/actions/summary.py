from psadmin_plus.actions.action import Action
        
class Summary(Action):

    def __init__(self):
        super().__init__()

    def process(self):
        self._psadmin(["-envsummary"])
