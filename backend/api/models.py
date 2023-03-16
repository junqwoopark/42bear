from django.db import models

# Create your models here.
class User(models.Model):
        name = models.CharField(max_length=50) # intra login
        time = models.TimeField() # time of login
        isLibftDone = models.BooleanField(default=False) # is libft done



